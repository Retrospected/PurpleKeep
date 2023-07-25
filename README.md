# Description 

With the rapidly increasing variety of attack techniques and a simultaneous rise in the number of detection rules offered by EDRs (Endpoint Detection and Response) and custom-created ones, the need for constant functional testing of detection rules has become evident. However, manually re-running these attacks and cross-referencing them with detection rules is a labor-intensive task which is worth automating.

To address this challenge, I developed "PurpleKeep," an open-source initiative designed to facilitate the automated testing of detection rules. Leveraging the capabilities of the [Atomic Red Team project](https://atomicredteam.io) which allows to simulate attacks following [MITRE TTPs](https://attack.mitre.org/) (Tactics, Techniques, and Procedures). PurpleKeep enhances the simulation of these TTPs to serve as a starting point for the  evaluation of the effectiveness of detection rules.

Automating the process of simulating one or multiple TTPs in a test environment comes with certain challenges, one of which is the contamination of the platform after multiple simulations. However, PurpleKeep aims to overcome this hurdle by streamlining the simulation process and facilitating the creation and instrumentation of the targeted platform.

Primarily developed as a proof of concept, PurpleKeep serves as an End-to-End Detection Rule Validation platform tailored for an Azure-based environment. It has been tested in combination with the automatic deployment of Microsoft Defender for Endpoint as the preferred EDR solution. PurpleKeep also provides support for security and audit policy configurations, allowing users to mimic the desired endpoint environment.

To facilitate analysis and monitoring, PurpleKeep integrates with Azure Monitor and Log Analytics services to store the simulation logs and allow further correlation with any events and/or alerts stored in the same platform.

TLDR: PurpleKeep provides an Attack Simulation platform to perform End-to-End Detection Rule Validation in an Azure-based environment.

## Requirements

The project is based on Azure Pipelines and requires the following to be able to run:
- Azure Service Connection to a resource group as described in the [Microsoft Docs](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml)
- Assignment of the "Key Vault Administrator" Role for the previously created Enterprise Application
- MDE onboarding script, placed as a Secure File in the Library of Azure DevOps and make it accessible to the  pipelines

### Optional

You can provide a security and/or audit policy file that will be loaded to mimic your Group Policy configurations. Use the Secure File option of the Library in Azure DevOps to make it accessible to your pipelines.

Refer to the [variables](variables.yml) file for your configurable items.

## Design

![PurpleKeep Design](./docs/PurpleKeep_1.0.jpg)

## Infrastructure

Deploying the infrastructure uses the Azure Pipeline to perform the following steps:
- Deploy Azure services:
    - Key Vault
    - Log Analytics Workspace
    - Data Connection Endpoint
    - Data Connection Rule
- Generate SSH keypair and password for the Windows account and store in the Key Vault
- Create a Windows 11 VM
- Install OpenSSH
- Configure and deploy the SSH public key
- Install Invoke-AtomicRedTeam 
- Install Microsoft Defender for Endpoint and configure exceptions
- (Optional) Apply security and/or audit policy files
- Reboot

## Simulation

Currently only the Atomics from the public repository are supported. The pipelines takes a Technique ID as input or a comma seperate list of techniques, for example:
- T1059.003
- T1027,T1049,T1003

The logs of the simulation are ingested into the AtomicLogs_CL table of the Log Analytics Workspace.

There are currently two ways to run the simulation:

### [Rotating simulation](rotate_simulation.yml)

This pipeline will deploy a fresh platform after the simulation of each TTP. The Log Analytic workspace will maintain the logs of each run.

**Warning: this will onboard a large number of hosts into your EDR**

### [Single deploy simulation](single_deploy_simulation.yml)

A fresh infrastructure will be deployed only at the beginning of the pipeline. All TTP's will be simulated on this instance. This is the fastests way to simulate and prevents onboarding a large number of devices, however running a lot of simulations in a same environment has the risk of contaminating the environment and making the simulations less stable and predictable.

## TODO

### Must have
* [x] Check if pre-reqs have been fullfilled before executing the atomic
* [x] Provide the ability to import own group policy
* [x] Cleanup biceps and pipelines by using a master template (Complete build)
* [x] Build pipeline that runs technique sequently with reboots in between
* [x] Add Azure ServiceConnection to variables instead of parameters

### Nice to have
* [ ] MDE Off-boarding (?)
* [ ] Automatically join and leave AD domain
* [ ] Make Atomics repository configureable
* [ ] Deploy VECTR as part of the infrastructure and ingest results during simulation. Also see the [VECTR API issue](https://github.com/SecurityRiskAdvisors/VECTR/issues/235)
* [ ] Tune alert API call to Microsoft Defender for Endpoint (Microsoft.Security alertsSuppressionRules)
* [ ] Add C2 infrastructure for manual or C2 based simulations

## Issues

* [ ] Atomics do not return if a simulation succeeded or not
* [ ] Unreliable OpenSSH extension installer failing infrastructure deployment
* [ ] Spamming onboarded devices in the EDR

## Credits

* [Splunk's Attack Range](https://github.com/splunk/attack_range)
* [Sp4rkCon 2023 - Continuous End-to-End Detection Validation and Reporting with Carrie Roberts](https://vimeo.com/819912016/c76af1ca39)
* [Red Canary's Coalmine](https://redcanary.com/blog/coalmine/)