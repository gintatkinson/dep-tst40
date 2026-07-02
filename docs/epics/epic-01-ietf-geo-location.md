---
title: "ietf-geo-location: Geographic Location"
type: "epic"
issue_id: 7
generation_mode: "subagent"
spec_source: "RFC 9179"
---

# Epic: ietf-geo-location: Geographic Location

## 1. Context
The IETF has standardized a YANG grouping for specifying geographic locations on or around any astronomical object. RFC 9179 defines the `ietf-geo-location` module which provides a reusable `geo-location` grouping. This grouping captures a frame of reference (astronomical body, geodetic datum, accuracy), location coordinates (ellipsoid or Cartesian), velocity vectors, and temporal metadata. The module supports both Earth-based locations (defaulting to WGS-84) and extraterrestrial contexts (Moon, Mars, comets), as well as alternate coordinate systems for virtual realities.

This Epic covers the complete structural extraction of all container, leaf, choice, and case nodes defined in the `ietf-geo-location@2022-02-11.yang` schema, translating them into platform-independent, implementation-ready Agile feature specifications.

## 2. Requirements & Checklist
- [ ] #1 - [Configure Reference Frame](https://github.com/gintatkinson/dep-tst40/blob/main/docs/features/feat-01-reference-frame.md) (Foundational container for frame of reference: astronomical body selection and alternate system support)
- [ ] #2 - [Configure Geodetic System](https://github.com/gintatkinson/dep-tst40/blob/main/docs/features/feat-02-geodetic-system.md) (Defines coordinate meaning via geodetic-datum and accuracy parameters)
- [ ] #3 - [Specify Ellipsoid Location Coordinates](https://github.com/gintatkinson/dep-tst40/blob/main/docs/features/feat-03-ellipsoid-location.md) (Latitude/longitude/height coordinate capture with ISO 6709:2008 conformance)
- [ ] #4 - [Specify Cartesian Location Coordinates](https://github.com/gintatkinson/dep-tst40/blob/main/docs/features/feat-04-cartesian-location.md) (X/Y/Z Cartesian coordinate capture, mutually exclusive with ellipsoid)
- [ ] #5 - [Track Velocity Vector](https://github.com/gintatkinson/dep-tst40/blob/main/docs/features/feat-05-velocity-vector.md) (3D velocity vector with speed and heading derivation formulas)
- [ ] #6 - [Record Temporal Metadata](https://github.com/gintatkinson/dep-tst40/blob/main/docs/features/feat-06-temporal-metadata.md) (Timestamp and validity window for location data lifecycle management)

### Associated Use Cases & User Stories

#### Associated Use Cases
- [ ] #13 - [Record Geographic Location Using Ellipsoid Coordinates](https://github.com/gintatkinson/dep-tst40/blob/main/docs/use-cases/uc-01-record-ellipsoid-location.md) (Primary deployment scenario for Earth-based geolocation with ISO 6709:2008 conformance)
- [ ] #14 - [Record Geographic Location Using Cartesian Coordinates](https://github.com/gintatkinson/dep-tst40/blob/main/docs/use-cases/uc-02-record-cartesian-location.md) (Non-Earth and virtual reality coordinate system deployment scenario)
- [ ] #15 - [Track Object Motion Using Velocity Vector](https://github.com/gintatkinson/dep-tst40/blob/main/docs/use-cases/uc-03-track-object-motion.md) (Motion tracking with speed/heading derivation and continental drift analysis)
- [ ] #16 - [Export Geolocation to External Portability Formats](https://github.com/gintatkinson/dep-tst40/blob/main/docs/use-cases/uc-04-export-location-formats.md) (Format export to IETF geo: URI, W3C, OGC GML, and Google KML standards)

#### Associated User Stories
- [ ] #8 - [Derive Speed and Heading from Velocity Vector](https://github.com/gintatkinson/dep-tst40/blob/main/docs/user-stories/us-01-derive-speed-heading.md) (Calculates 2D speed and heading from v-north/v-east velocity components using RFC 9179 formulas)
- [ ] #9 - [Manage Location Data Temporal Lifecycle](https://github.com/gintatkinson/dep-tst40/blob/main/docs/user-stories/us-02-temporal-lifecycle.md) (Manages validity windows and expiration detection using timestamp and valid-until)
- [ ] #10 - [Inherit Reference Frame in Nested Locations](https://github.com/gintatkinson/dep-tst40/blob/main/docs/user-stories/us-03-nested-reference-frame.md) (Enables hierarchical reference-frame inheritance for nested location containers)
- [ ] #11 - [Export Geolocation to IETF geo: URI Format](https://github.com/gintatkinson/dep-tst40/blob/main/docs/user-stories/us-04-geo-uri-mapping.md) (Maps YANG geolocation to RFC 5870 geo: URI format for URI-based interoperability)
- [ ] #12 - [Export Geolocation to W3C, GML, and KML Portability Formats](https://github.com/gintatkinson/dep-tst40/blob/main/docs/user-stories/us-05-portability-formats.md) (Maps YANG geolocation to W3C, OGC GML, and Google KML standard portability formats)
## 3. Architecture and System Interaction Diagrams

### Subsystem Component Definition
The Geo Location subsystem provides a standardized interface for specifying and querying geographic locations on any astronomical body, with support for multiple coordinate systems and motion tracking.

### System-Level UML Class Diagram
```mermaid
classDiagram
    class GeoLocationSubsystem {
        <<component>>
        +configureReferenceFrame() : Boolean [1]
        +configureGeodeticSystem() : Boolean [1]
        +specifyEllipsoidLocation() : Boolean [1]
        +specifyCartesianLocation() : Boolean [1]
        +trackVelocity() : Boolean [1]
        +recordTimestamp() : Boolean [1]
    }
    class GeoLocation {
        +String timestamp [0..1]
        +String validUntil [0..1]
    }
    class ReferenceFrame {
        +String alternateSystem [0..1]
        +String astronomicalBody [1]
    }
    class GeodeticSystem {
        +String geodeticDatum [0..1]
        +Real coordAccuracy [0..1]
        +Real heightAccuracy [0..1]
    }
    class LocationChoice {
        <<choice>>
    }
    class EllipsoidLocation {
        +Real latitude [0..1]
        +Real longitude [0..1]
        +Real height [0..1]
    }
    class CartesianLocation {
        +Real x [0..1]
        +Real y [0..1]
        +Real z [0..1]
    }
    class Velocity {
        +Real vNorth [0..1]
        +Real vEast [0..1]
        +Real vUp [0..1]
    }
    GeoLocationSubsystem *-- GeoLocation
    GeoLocation *-- ReferenceFrame
    ReferenceFrame *-- GeodeticSystem
    GeoLocation *-- LocationChoice
    LocationChoice <|-- EllipsoidLocation
    LocationChoice <|-- CartesianLocation
    GeoLocation *-- Velocity

    MotionTrackingService --> Velocity : uses
    MotionTrackingService --> SpeedHeadingCalculator : delegates to
    GeoLocationRegistry --> GeoLocation : manages
    GeoLocationRegistry --> SystemClock : queries
    LocationDataConsumer --> GeoLocationRegistry : queries
    LocationHierarchyManager --> GeoLocation : manages hierarchy
    LocationExporter --> GeoLocation : reads
    LocationExporter --> GeoUriBuilder : delegates to
    FormatMapper --> GeoLocation : reads
    FormatMapper --> W3CGeolocationAdapter : delegates W3C
    FormatMapper --> GMLPositionAdapter : delegates GML
    FormatMapper --> SpeedHeadingCalculator : computes speed/heading
    W3CGeolocationAdapter --> SpeedHeadingCalculator : computes speed/heading

    class MotionTrackingService {
        <<service>>
        +computeSpeed(vNorth : Real, vEast : Real) : Real [1]
        +computeHeading(vNorth : Real, vEast : Real) : Real [1]
    }
    class SpeedHeadingCalculator {
        <<service>>
        +computeSpeed(vNorth : Real, vEast : Real) : Real [1]
        +computeHeading(vNorth : Real, vEast : Real) : Real [1]
    }
    class LocationDataConsumer {
        <<actor>>
    }
    class GeoLocationRegistry {
        <<service>>
        +getLocation(locationId : String) : GeoLocation [1]
        +getCurrentTime() : String [1]
    }
    class SystemClock {
        <<service>>
        +getCurrentTime() : String [1]
    }
    class LocationHierarchyManager {
        <<service>>
    }
    class LocationExporter {
        <<service>>
    }
    class GeoUriBuilder {
        <<service>>
        +build(latitude : Real, longitude : Real, datum : String, accuracy : Real, height : Real) : String [1]
    }
    class FormatMapper {
        <<service>>
        +getFullLocation() : FullLocationData [1]
    }
    class W3CGeolocationAdapter {
        <<service>>
        +toGeolocationPosition(fullData : FullLocationData) : GeolocationPosition [1]
    }
    class GMLPositionAdapter {
        <<service>>
        +toGMLPosition(fullData : FullLocationData) : GMLPosition [1]
    }
```

### System State Machine Diagram
```mermaid
stateDiagram-v2
    [*] --> Unconfigured
    Unconfigured --> Configured : configureReferenceFrame / setAstronomicalBody
    Configured --> Located : specifyLocation / setCoordinates
    Located --> InMotion : trackVelocity / setVelocityVector
    InMotion --> Located : velocityCeased / clearVelocity
    Located --> Expired : validUntilElapsed / timePastExpiry
    Expired --> Located : updateTimestamp / setNewTimestamp
    Configured --> Unconfigured : clearReferenceFrame / reset
    Located --> Configured : clearLocation / resetCoordinates
    InMotion --> Located : clearLocation / resetCoordinates
```

## 4. Operational Considerations
The geolocation grouping is designed for integration into YANG data models that manage network elements. It supports operational workflows including:
- **Location Audit:** Operators can query the timestamp and valid-until fields to identify stale location data requiring refresh
- **Nested Location Management:** When modeling hierarchical infrastructure (data center → rack → device), child locations may inherit reference-frame configuration from parent containers
- **Motion-Aware Operations:** The velocity vector enables tracking of slowly moving elements (tectonic drift, satellite orbital motion) with time-correlated updates
- **Format Interoperability:** Location data can be exported to IETF geo: URI (RFC 5870), W3C Geolocation API, OGC GML, and Google KML formats for integration with external systems
- **Multi-Body Operations:** The same grouping supports location recording on Earth, Moon, Mars, and other astronomical bodies, enabling operations in interplanetary network scenarios

## 5. Security & Governance
Per RFC 9179 Section 7, the YANG module defines writable/creatable/deletable data nodes. While none of these nodes are by themselves considered more sensitive than standard configuration, the grouping identifies geographic locations — module authors SHOULD consider privacy issues when the data is readable (e.g., customer device locations). Access control SHOULD be enforced via NETCONF Access Control Model (RFC 8341) or equivalent mechanisms.

Governance:
- **IANA Registry:** The "Geodetic System Values" registry under the "YANG Geographic Location Parameters" registry (RFC 9179 Section 6.1) governs standard geodetic system names with First Come First Served policy
- **Schema Authority:** The normative specification (RFC 9179) and structural schema (ietf-geo-location@2022-02-11.yang) are the authoritative references. Where they conflict, the schema is authoritative for structural completeness; the normative text is authoritative for behavioral semantics.

## 6. Source References
Structural Schema: [ietf-geo-location@2022-02-11.yang](https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-geo-location%402022-02-11.yang)
Normative Specification: [RFC 9179 - A YANG Grouping for Geographic Locations](https://datatracker.ietf.org/doc/rfc9179/)
