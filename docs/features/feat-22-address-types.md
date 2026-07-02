---
title: "Define Physical Address Types"
type: "feature"
issue_id: 22
interface_type: "api"
generation_mode: "subagent"
spec_source: "RFC 9911"
---

# Feature: Define Physical Address Types

## Parent Epic
- [ ] #2 - [ietf-yang-types: Common YANG Data Types](https://github.com/gintatkinson/dep-tst40/blob/main/docs/epics/epic-02-ietf-yang-types.md) (Physical address types represent hardware-level addressing for the YANG type library)

## Description
Physical address types model media- or hardware-level addresses using colon-separated hexadecimal octets in canonical lowercase form. phys-address supports variable-length address representations, accepting zero or more octets, making it suitable for any media or physical address including non-standard MACs. mac-address is a specialization constrained to exactly 6 octets (48 bits) conforming to the IEEE 802 MAC address format. Both types are equivalent to their SMIv2 counterparts: PhysAddress and MacAddress, respectively. Non-48-bit IEEE 802 MAC addresses must use phys-address instead.

## UML Class Diagram
```mermaid
classDiagram
    class PhysAddress {
        &lt;&lt;typedef&gt;&gt;
        +baseType : String [1]
        +format : String [1]
        +variableLength : Boolean [1]
        +canonicalCase : String [1]
        +smiEquivalent : String [1]
    }
    class MacAddress {
        &lt;&lt;typedef&gt;&gt;
        +baseType : String [1]
        +format : String [1]
        +fixedLength : Integer [1]
        +bitLength : Integer [1]
        +standard : String [1]
        +canonicalCase : String [1]
        +smiEquivalent : String [1]
    }
    PhysAddress &lt;|-- MacAddress
```

## Interface Requirements

### 1. Payload Schema
```json
{ "phys-address": "00:1a:2b:3c:4d:5e", "mac-address": "f8:1d:4f:ae:7d:ec" }
```
```json
{ "phys-address": "", "mac-address": "00:00:00:00:00:00" }
```
```json
{ "phys-address": "de:ad:be:ef" }
```
```json
{ "phys-address": "01:02:03:04:05:06:07:08:09:0a" }
```

### 2. Validation & Constraints

| Field | Type | Multiplicity | Pattern | Constraints |
|---|---|---|---|---|
| phys-address | String | 0..1 | `([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?` | Variable number of hex octets (0..n) separated by colons. Each octet is exactly 2 hex digits. Canonical form is lowercase. Equivalent to SMIv2 PhysAddress. |
| mac-address | String | 0..1 | `[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}` | Exactly 6 octets (48 bits). Each octet is exactly 2 hex digits separated by colons. Canonical form is lowercase. Conforms to IEEE 802 MAC address format. Equivalent to SMIv2 MacAddress. |

### 3. Logical Operations

| Operation | Description |
|---|---|
| Parse address string | Split colon-separated hex string into octets; validate each octet is exactly 2 hex digits; verify octet count constraints |
| Normalize to canonical lowercase | Convert all hex digits a-f and A-F to lowercase; preserve octet count and colon separators |
| Validate phys-address | Accept empty string or any number of hex octets separated by colons; reject invalid hex characters and malformed octets |
| Validate mac-address | Require exactly 6 octets; reject any other octet count; reject empty string; reject invalid hex characters |
| Compare addresses | Compare two address values case-insensitively after normalization; addresses differing only in hex case are considered equal |
| Determine if address is IEEE 802 MAC | Check if the address string matches the mac-address pattern (exactly 6 octets); return boolean |

### 4. Exception States

| Error Code | Condition | Message |
|---|---|---|
| 422 | phys-address contains invalid hex characters (g-z, G-Z) | "phys-address contains invalid hexadecimal characters" |
| 422 | phys-address contains non-colon separator (hyphen, space, dot) | "phys-address octets must be separated by colons" |
| 422 | phys-address contains an octet with odd number of hex digits | "phys-address octet must contain exactly 2 hexadecimal digits" |
| 422 | mac-address is an empty string | "mac-address must contain exactly 6 octets (48 bits)" |
| 422 | mac-address contains invalid hex characters (g-z, G-Z) | "mac-address contains invalid hexadecimal characters" |
| 422 | mac-address contains non-colon separator | "mac-address octets must be separated by colons" |
| 422 | mac-address has fewer than 6 octets (e.g., 5 octets) | "mac-address must contain exactly 6 octets (48 bits); got N octets" |
| 422 | mac-address has more than 6 octets (e.g., 7 octets) | "mac-address must contain exactly 6 octets (48 bits); got N octets" |
| 422 | mac-address contains an octet with odd number of hex digits | "mac-address octet must contain exactly 2 hexadecimal digits" |
| 422 (guidance) | Non-48-bit IEEE 802 MAC address submitted as mac-address | "non-48-bit MAC addresses must use phys-address instead of mac-address" |
| 200 (normalized) | Uppercase hex digits provided as input | Address is accepted and stored in canonical lowercase form |
| 200 (normalized) | Mixed-case hex digits provided as input | Address is accepted; all hex digits lowercased in stored canonical form |

## Given-When-Then Acceptance Criteria

### AC-01: Valid phys-address with Variable Length (6 Octets)
- **Given** a phys-address typedef interface
- **When** the value "00:1a:2b:3c:4d:5e" is submitted
- **Then** the value is accepted and stored as "00:1a:2b:3c:4d:5e"

### AC-02: Valid phys-address with Single Octet
- **Given** a phys-address typedef interface
- **When** the value "ff" is submitted
- **Then** the value is accepted and stored as "ff"

### AC-03: Valid phys-address with Extended Length (10 Octets)
- **Given** a phys-address typedef interface
- **When** the value "01:02:03:04:05:06:07:08:09:0a" is submitted
- **Then** the value is accepted and stored as "01:02:03:04:05:06:07:08:09:0a"

### AC-04: Valid phys-address Empty String
- **Given** a phys-address typedef interface
- **When** the value "" (empty string) is submitted
- **Then** the value is accepted and stored as an empty string

### AC-05: Valid mac-address Exactly 6 Octets (48 Bits)
- **Given** a mac-address typedef interface
- **When** the value "f8:1d:4f:ae:7d:ec" is submitted
- **Then** the value is accepted and stored as "f8:1d:4f:ae:7d:ec"

### AC-06: Valid mac-address Broadcast Address
- **Given** a mac-address typedef interface
- **When** the value "ff:ff:ff:ff:ff:ff" is submitted
- **Then** the value is accepted and stored as "ff:ff:ff:ff:ff:ff"

### AC-07: Canonical Lowercase — Uppercase Input
- **Given** a phys-address typedef interface
- **When** the value "00:1A:2B:3C:4D:5E" (uppercase hex digits) is submitted
- **Then** the input is accepted and stored in canonical lowercase as "00:1a:2b:3c:4d:5e"

### AC-08: Canonical Lowercase — Mixed-Case Input
- **Given** a mac-address typedef interface
- **When** the value "F8:1d:4F:Ae:7D:ec" (mixed-case hex digits) is submitted
- **Then** the input is accepted and stored in canonical lowercase as "f8:1d:4f:ae:7d:ec"

### AC-09: Canonical Lowercase — mac-address Uppercase Input
- **Given** a mac-address typedef interface
- **When** the value "AA:BB:CC:DD:EE:FF" is submitted
- **Then** the input is accepted and stored in canonical lowercase as "aa:bb:cc:dd:ee:ff"

### AC-10: Invalid Hex Character Rejection — phys-address
- **Given** a phys-address typedef interface
- **When** the value "gg:11:22:33:44:55" is submitted (contains 'g')
- **Then** the operation fails with error 422 and message "phys-address contains invalid hexadecimal characters"

### AC-11: Invalid Hex Character Rejection — mac-address
- **Given** a mac-address typedef interface
- **When** the value "zz:11:22:33:44:55" is submitted (contains 'z')
- **Then** the operation fails with error 422 and message "mac-address contains invalid hexadecimal characters"

### AC-12: mac-address Wrong Octet Count — Too Few (5 Octets)
- **Given** a mac-address typedef interface
- **When** the value "00:1a:2b:3c:4d" (5 octets) is submitted
- **Then** the operation fails with error 422 and message "mac-address must contain exactly 6 octets (48 bits); got 5 octets"

### AC-13: mac-address Wrong Octet Count — Too Many (7 Octets)
- **Given** a mac-address typedef interface
- **When** the value "00:1a:2b:3c:4d:5e:6f" (7 octets) is submitted
- **Then** the operation fails with error 422 and message "mac-address must contain exactly 6 octets (48 bits); got 7 octets"

### AC-14: mac-address Rejects Empty String
- **Given** a mac-address typedef interface
- **When** the value "" (empty string) is submitted
- **Then** the operation fails with error 422 and message "mac-address must contain exactly 6 octets (48 bits)"

### AC-15: mac-address Rejects Single Octet
- **Given** a mac-address typedef interface
- **When** the value "ff" (1 octet) is submitted
- **Then** the operation fails with error 422 and message "mac-address must contain exactly 6 octets (48 bits); got 1 octets"

### AC-16: Non-Colon Separator Rejection — phys-address
- **Given** a phys-address typedef interface
- **When** the value "00-1a-2b-3c-4d-5e" (hyphen-separated) is submitted
- **Then** the operation fails with error 422 and message "phys-address octets must be separated by colons"

### AC-17: Non-Colon Separator Rejection — mac-address
- **Given** a mac-address typedef interface
- **When** the value "00.1a.2b.3c.4d.5e" (dot-separated) is submitted
- **Then** the operation fails with error 422 and message "mac-address octets must be separated by colons"

### AC-18: Odd Hex Digits in Octet Rejection — phys-address
- **Given** a phys-address typedef interface
- **When** the value "0:1a:2b:3c:4d:5e" (first octet has 1 digit) is submitted
- **Then** the operation fails with error 422 and message "phys-address octet must contain exactly 2 hexadecimal digits"

### AC-19: Odd Hex Digits in Octet Rejection — mac-address
- **Given** a mac-address typedef interface
- **When** the value "000:1a:2b:3c:4d:5e" (first octet has 3 digits) is submitted
- **Then** the operation fails with error 422 and message "mac-address octet must contain exactly 2 hexadecimal digits"

### AC-20: Non-48-Bit Address Guidance — phys-address for Non-Standard MACs
- **Given** a non-48-bit IEEE 802 MAC address value "00:1a:2b:3c:4d:5e:6f:70" (8 octets)
- **When** this value needs to be represented
- **Then** it must be stored as a phys-address, not as a mac-address

### AC-21: IEEE 802 MAC Address Format Conformance
- **Given** a mac-address with value "00:1a:2b:3c:4d:5e"
- **When** validated against the IEEE 802 MAC address specification (Section 8.1 of IEEE Std 802-2014)
- **Then** the format of 6 colon-separated hex octets representing a 48-bit address conforms to IEEE 802

### AC-22: SMIv2 PhysAddress Equivalence
- **Given** the phys-address typedef with pattern `([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?` and canonical lowercase
- **When** the type is compared against the SMIv2 PhysAddress specification (RFC 2579)
- **Then** the value set and representation are equivalent to SMIv2 PhysAddress

### AC-23: SMIv2 MacAddress Equivalence
- **Given** the mac-address typedef with pattern `[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}` and canonical lowercase
- **When** the type is compared against the SMIv2 MacAddress textual convention (RFC 2579)
- **Then** the value set and representation are equivalent to SMIv2 MacAddress

### AC-24: Case-Insensitive Address Comparison
- **Given** two phys-address values "aa:bb:cc" and "AA:BB:CC"
- **When** compared for equality
- **Then** they are considered equal because they differ only in hex digit case

### AC-25: Case-Insensitive Address Comparison — mac-address
- **Given** two mac-address values "f8:1d:4f:ae:7d:ec" and "F8:1D:4F:AE:7D:EC"
- **When** compared for equality
- **Then** they are considered equal because they differ only in hex digit case

### AC-26: phys-address Accepts Zero Octets (Empty)
- **Given** a phys-address typedef interface
- **When** the zero-length (empty string) value is read back
- **Then** the stored value is "" (empty string), representing no physical address

### AC-27: mac-address Rejects Zero Octets
- **Given** a mac-address typedef interface
- **When** a zero-length representation is attempted
- **Then** the operation fails because mac-address requires exactly 6 octets

### AC-28: phys-address Preserves Octet Count Through Round-Trip
- **Given** a phys-address value "de:ad:be:ef" (4 octets)
- **When** the value is stored and then read back
- **Then** the returned value is "de:ad:be:ef", preserving both the octet count and canonical lowercase form

### AC-29: mac-address Preserves Canonical Form Through Round-Trip
- **Given** a mac-address input "00:00:00:00:00:00"
- **When** the value is stored and then read back
- **Then** the returned value is "00:00:00:00:00:00"

## Specification Context (Verbatim)
The following paragraph is quoted from RFC 9911 Section 3.

> The phys-address type represents media- or physical-level addresses as a sequence of octets, each octet represented by two hexadecimal numbers separated by colons. The canonical representation uses lowercase characters. The mac-address type represents a 48-bit IEEE 802 MAC address. Note that there are IEEE 802 MAC addresses with a different length that this type cannot represent.

## 4. Source References
Structural Schema: [ietf-yang-types@2025-12-22.yang](https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-yang-types%402025-12-22.yang)
Normative Specification: [RFC 9911](https://datatracker.ietf.org/doc/rfc9911/)
