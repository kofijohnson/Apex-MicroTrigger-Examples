# MicroTrigger Examples

This repo contains some examples of Trigger Development using the [MicroTrigger Framework](https://github.com/kofijohnson/Apex-MicroTrigger).

## Deploy the MicroTrigger Examples

The MicroTrigger Examples is dependent on the [MicroTrigger Framework](https://github.com/kofijohnson/Apex-MicroTrigger) so it needs to be installed/deployed in the Org or Scratch Org first.

1. Clone the [MicroTrigger Framework repo](https://github.com/kofijohnson/Apex-MicroTrigger), then create an Unlocked Package and Unlocked Package version. In the [sfdx-project.json](https://github.com/kofijohnson/Apex-MicroTrigger/blob/master/sfdx-project.json) file, replace the MICROTRIGGERFRAMEWORK_PACKAGE_ID with the created Package ID.
3. Clone the current repo then deploy to your Scratch Org.

## Project Artifacts

The MicroTrigger Examples project has 2 artifacts: 

* Common
This artifact contains the common components (Schema, Layouts, Objects Profiles and Apex Triggers). 

* Rollups
This artifact some examples of Rollups logic. In this example, we create some rollup trigger logic from Payment Object to Opportunity and Account. 