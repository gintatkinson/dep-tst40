---
title: "Define Gauge Types"
type: "feature"
issue_id: 18
interface_type: "api"
generation_mode: "subagent"
spec_source: "RFC 9911"
---

# Feature: Define Gauge Types

## Parent Epic
- [ ] #2 - [ietf-yang-types: Common YANG Data Types](https://github.com/gintatkinson/dep-tst40/blob/main/docs/epics/epic-02-ietf-yang-types.md) (Gauge types capture variable-magnitude values for the YANG type library)

## Description
Gauge types model non-negative integers that may both increase and decrease in response to real-world information changes — unlike counters, which only increase. gauge32 (base type uint32) and gauge64 (base type uint64) each enforce a bounded range [0..max] with latching behavior: when the modeled information exceeds the maximum, the gauge latches at the maximum; when it falls below the minimum, it latches at zero. The gauge resumes tracking the modeled value once it returns within bounds. gauge32 is equivalent to SMIv2 Gauge32; gauge64 is equivalent to SMIv2 CounterBasedGauge64.

## UML Class Diagram
```mermaid
classDiagram
    class Gauge32 {
        +baseType : String [1]
        +maxValue : Integer [1]
        +minValue : Integer [1]
        +latchesAtBounds : Boolean [1]
    }
    class Gauge64 {
        +baseType : String [1]
        +maxValue : Integer [1]
        +minValue : Integer [1]
        +latchesAtBounds : Boolean [1]
    }
    Gauge32 <|-- Gauge64
    Gauge32 &lt;|-- Gauge64
```

## Interface Requirements

### 1. Payload Schema
```json
{ "gauge32": 1500000000, "gauge64": 5000000000000 }
```

### 2. Validation & Constraints

| Field | Type | Range | Latching | Behavior |
|---|---|---|---|---|
| gauge32 | uint32 | [0 .. 4294967295] | Yes | Bidirectional (increase and decrease). Latches at max when modeled value >= max. Latches at min when modeled value <= min. Resumes tracking when value returns within bounds. |
| gauge64 | uint64 | [0 .. 18446744073709551615] | Yes | Bidirectional (increase and decrease). Same latching semantics as gauge32. Equivalent to SMIv2 CounterBasedGauge64 (RFC 2856). |

### 3. Logical Operations & Interface Messages

| Operation | Description |
|---|---|
| Read current gauge value | Return the stored gauge32 or gauge64 value, which may differ from the raw modeled value if latching is active |
| Detect gauge saturation | Determine whether the gauge is currently latched at max or min, indicating the modeled information is outside bounds |
| Track gauge value changes over time | Observe gauge value deltas to monitor trends, accounting for latching plateaus |

### 4. Logical Exception States & Validation Failures

| Error Code | Condition | Message |
|---|---|---|
| 422 | gauge32 value is negative | "gauge32 must be a non-negative integer in range [0..4294967295]" |
| 422 | gauge32 value exceeds 4294967295 | "gauge32 value exceeds maximum 4294967295" |
| 422 | gauge64 value is negative | "gauge64 must be a non-negative integer in range [0..18446744073709551615]" |
| 422 | gauge64 value exceeds 18446744073709551615 | "gauge64 value exceeds maximum 18446744073709551615" |
| 200 (latched) | Modeled information >= max value; gauge reports max | Gauge saturated at max value |
| 200 (latched) | Modeled information <= min value; gauge reports 0 | Gauge saturated at min value |
| — (internal) | Modeled value decreases below latched max | Gauge resumes tracking from the decreased value once within bounds |
| — (internal) | Modeled value increases above latched min | Gauge resumes tracking from the increased value once within bounds |

## Given-When-Then Acceptance Criteria

### AC-01: gauge32 Within Bounds
- **Given** a gauge32 is initialized to 0
- **When** the modeled information is set to 1500000000
- **Then** the gauge32 value reads 1500000000

### AC-02: gauge32 Latches at Maximum (2^32-1)
- **Given** a gauge32 has a current value of 4294967290
- **When** the modeled information increases to 4294967300 (exceeds max 4294967295)
- **Then** the gauge32 value reads 4294967295 and is flagged as latched at max

### AC-03: gauge32 Latches at Minimum (0)
- **Given** a gauge32 has a current value of 10
- **When** the modeled information decreases to -100 (below 0)
- **Then** the gauge32 value reads 0 and is flagged as latched at min

### AC-04: gauge64 Within Bounds
- **Given** a gauge64 is initialized to 0
- **When** the modeled information is set to 5000000000000
- **Then** the gauge64 value reads 5000000000000

### AC-05: gauge64 Latches at Maximum (2^64-1)
- **Given** a gauge64 has a current value of 18446744073709551610
- **When** the modeled information increases to 18446744073709552000 (exceeds max)
- **Then** the gauge64 value reads 18446744073709551615 and is flagged as latched at max

### AC-06: gauge64 Latches at Minimum (0)
- **Given** a gauge64 has a current value of 100
- **When** the modeled information decreases to -500 (below 0)
- **Then** the gauge64 value reads 0 and is flagged as latched at min

### AC-07: gauge32 Recovery from Max Latch
- **Given** a gauge32 is latched at 4294967295 because the modeled value exceeded the max
- **When** the modeled information decreases to 2000000000 (within bounds)
- **Then** the gauge32 value reads 2000000000 and is no longer flagged as latched

### AC-08: gauge32 Recovery from Min Latch
- **Given** a gauge32 is latched at 0 because the modeled value fell below 0
- **When** the modeled information increases to 500 (within bounds)
- **Then** the gauge32 value reads 500 and is no longer flagged as latched

### AC-09: gauge64 Recovery from Max Latch
- **Given** a gauge64 is latched at 18446744073709551615
- **When** the modeled information decreases to 9000000000000000000 (within bounds)
- **Then** the gauge64 value reads 9000000000000000000 and is no longer flagged as latched

### AC-10: gauge64 Recovery from Min Latch
- **Given** a gauge64 is latched at 0
- **When** the modeled information increases to 7500000000000000000 (within bounds)
- **Then** the gauge64 value reads 7500000000000000000 and is no longer flagged as latched

### AC-11: gauge32 Rejects Negative Value
- **Given** a gauge32 interface
- **When** a client attempts to write the value -1
- **Then** the operation fails with error 422 and message "gauge32 must be a non-negative integer in range [0..4294967295]"

### AC-12: gauge64 Rejects Negative Value
- **Given** a gauge64 interface
- **When** a client attempts to write the value -1
- **Then** the operation fails with error 422 and message "gauge64 must be a non-negative integer in range [0..18446744073709551615]"

### AC-13: gauge32 Rejects Value Exceeding Maximum
- **Given** a gauge32 interface
- **When** a client attempts to write the value 4294967296 (max + 1)
- **Then** the operation fails with error 422 and message "gauge32 value exceeds maximum 4294967295"

### AC-14: gauge64 Rejects Value Exceeding Maximum
- **Given** a gauge64 interface
- **When** a client attempts to write the value 18446744073709551616 (max + 1)
- **Then** the operation fails with error 422 and message "gauge64 value exceeds maximum 18446744073709551615"

### AC-15: gauge32 Accepts Boundary Value 0
- **Given** a gauge32 interface
- **When** the value 0 is written as the gauge32 value
- **Then** the operation succeeds and gauge32 reads 0

### AC-16: gauge32 Accepts Boundary Value 4294967295
- **Given** a gauge32 interface
- **When** the value 4294967295 is written as the gauge32 value
- **Then** the operation succeeds and gauge32 reads 4294967295

### AC-17: gauge64 Accepts Boundary Value 0
- **Given** a gauge64 interface
- **When** the value 0 is written as the gauge64 value
- **Then** the operation succeeds and gauge64 reads 0

### AC-18: gauge64 Accepts Boundary Value 18446744073709551615
- **Given** a gauge64 interface
- **When** the value 18446744073709551615 is written as the gauge64 value
- **Then** the operation succeeds and gauge64 reads 18446744073709551615

### AC-19: gauge32 Increase from Max Latch — Retains Max
- **Given** a gauge32 is already latched at 4294967295
- **When** the modeled information increases further to 5000000000
- **Then** the gauge32 value remains 4294967295 and remains flagged as latched at max

### AC-20: gauge32 Decrease from Min Latch — Retains Min
- **Given** a gauge32 is already latched at 0
- **When** the modeled information decreases further to -200
- **Then** the gauge32 value remains 0 and remains flagged as latched at min

### AC-21: gauge32 SMIv2 Gauge32 Equivalence
- **Given** the gauge32 typedef derives from uint32 with range [0..4294967295] and latching semantics as defined by RFC 2578
- **When** the type is compared against the SMIv2 Gauge32 specification
- **Then** the value set and semantics are equivalent to SMIv2 Gauge32

### AC-22: gauge64 SMIv2 CounterBasedGauge64 Equivalence
- **Given** the gauge64 typedef derives from uint64 with range [0..18446744073709551615] and latching semantics as defined by RFC 2856
- **When** the type is compared against the SMIv2 CounterBasedGauge64 textual convention
- **Then** the value set and semantics are equivalent to SMIv2 CounterBasedGauge64

### AC-23: gauge32 Rejects Floating-Point Value
- **Given** a gauge32 interface
- **When** a client attempts to write the value 100.5
- **Then** the operation fails with error 422 because gauge32 requires an integer value

### AC-24: gauge64 Rejects Floating-Point Value
- **Given** a gauge64 interface
- **When** a client attempts to write the value 3.14
- **Then** the operation fails with error 422 because gauge64 requires an integer value

### AC-25: gauge32 Rejects Non-Numeric Value
- **Given** a gauge32 interface
- **When** a client attempts to write the string "abc" as the gauge32 value
- **Then** the operation fails with error 422 indicating the value is not a valid non-negative integer

### AC-26: gauge64 Rejects Null Value
- **Given** a gauge64 interface
- **When** a client attempts to set gauge64 to null
- **Then** the operation fails with error 422 indicating the value is required

## Specification Context (Verbatim)
The following paragraphs are quoted from RFC 9911 Section 3.

> The gauge32 type represents a non-negative integer, which may increase or decrease, but shall never exceed a maximum value, nor fall below a minimum value. The maximum value cannot be greater than 2^32-1 (4294967295 decimal), and the minimum value cannot be smaller than 0. The value of a gauge32 has its maximum value whenever the information being modeled is greater than or equal to its maximum value, and has its minimum value whenever the information being modeled is smaller than or equal to its minimum value. If the information being modeled subsequently decreases below the maximum value, the gauge32 also decreases; likewise, if the information increases above the minimum value, the gauge32 also increases.

> The gauge64 type represents a non-negative integer, which may increase or decrease, but shall never exceed a maximum value, nor fall below a minimum value. The maximum value cannot be greater than 2^64-1 (18446744073709551615), and the minimum value cannot be smaller than 0. The value of a gauge64 has its maximum value whenever the information being modeled is greater than or equal to its maximum value, and has its minimum value whenever the information being modeled is smaller than or equal to its minimum value. If the information being modeled subsequently decreases below (increases above) the maximum (minimum) value, the gauge64 also decreases (increases).

## 4. Source References
Structural Schema: [ietf-yang-types@2025-12-22.yang](https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-yang-types%402025-12-22.yang)
Normative Specification: [RFC 9911](https://datatracker.ietf.org/doc/rfc9911/)
