---
title: "Derive Speed and Heading from Velocity Vector"
type: "user-story"
issue_id: 8
generation_mode: "subagent"
spec_source: "RFC 9179"
---

# User Story: Derive Speed and Heading from Velocity Vector

## Parent Epic
- [ ] #7 - [ietf-geo-location: Geographic Location](https://github.com/gintatkinson/dep-tst40/blob/main/docs/epics/epic-01-ietf-geo-location.md) (Speed and heading are derived behavioral outputs from the velocity vector data captured in the geolocation grouping)

## Domain Object Mapping
- **Primary Domain Objects:** Velocity (container with v-north, v-east, v-up leafs), GeoLocation (containing container)
- **Actor/Role:** MotionTrackingService — the system component responsible for computing derived navigational values from raw velocity components

## BDD Scenario (OOA/OOD Realization)
**Given** a geo-location object has velocity vector components v-north and v-east with defined values
**When** the system computes derived navigational parameters
**Then** the system returns speed as the Euclidean magnitude sqrt(v-north² + v-east²) and heading as the arctangent arctan(v-east / v-north) relative to true north

**As a** MotionTrackingService
**I want to** calculate 2D speed and heading from raw v-north and v-east velocity components
**So that** the object's motion can be expressed in standard navigational terms suitable for display, logging, and portability mapping

## UML Sequence Diagram
```mermaid
sequenceDiagram
    autonumber
    actor motionService as "motionService : MotionTrackingService"
    participant geoLocation as "geoLocation : GeoLocation"
    participant velocity as "velocity : Velocity"
    participant calculator as "calculator : SpeedHeadingCalculator"

    motionService->>geoLocation: getVelocity()
    geoLocation->>velocity: getComponents()
    velocity-->geoLocation: vNorth : Real, vEast : Real
    geoLocation-->motionService: vNorth : Real, vEast : Real

    motionService->>calculator: computeSpeed(vNorth : Real, vEast : Real)
    calculator-->motionService: speed : Real

    motionService->>calculator: computeHeading(vNorth : Real, vEast : Real)
    calculator-->motionService: heading : Real
```

## UML State Machine Diagram
```mermaid
stateDiagram-v2
    [*] --> Stationary : v-north=0 AND v-east=0
    Stationary --> MovingNorth : v-north > 0 / speed = v-north, heading = 0
    Stationary --> MovingEast : v-north = 0 AND v-east > 0 / speed = v-east, heading = 90
    Stationary --> MovingQuadrant : v-north != 0 AND v-east != 0 / heading = arctan(v-east/v-north)
    MovingNorth --> Stationary : v-north reaches 0
    MovingEast --> Stationary : v-east reaches 0
    MovingQuadrant --> Stationary : both components reach 0
    MovingQuadrant --> MovingNorth : v-east reaches 0
    MovingQuadrant --> MovingEast : v-north reaches 0
```

## Operational Context
> To derive the two-dimensional heading and speed, one would use the following formulas:
> - speed = sqrt(v_north² + v_east²)
> - heading = arctan(v_east / v_north)
> For some applications that demand high accuracy and where the data is infrequently updated, this velocity vector can track very slow movement such as continental drift.

## Required Features Matrix
- [ ] #5 - [Track Velocity Vector](https://github.com/gintatkinson/dep-tst40/blob/main/docs/features/feat-05-velocity-vector.md) (The velocity vector leafs v-north and v-east are the input values for speed and heading derivation formulas)

## Source References
Structural Schema: [ietf-geo-location@2022-02-11.yang](https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-geo-location%402022-02-11.yang)
Normative Specification: [RFC 9179](https://datatracker.ietf.org/doc/rfc9179/)
