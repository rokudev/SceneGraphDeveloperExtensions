# Roku Component Library

## Overview

Roku Component Library (RCL) is a collection of Roku Scene Graph (RSG) components that enable rapid development of channels that follow Roku's best practices.

### Views

RCL views are full screen components. If you've built channels using the legacy Roku SDK this will be familiar to you. Using an RCL view saves you the effort of building a screen from scratch using lower level RSG components.

### Content Manager

RCL includes a robust content manager that makes it easy to connect a view to a content source like a feed or API. Using the RCL content manager saves you the effort of having to manage RSG Task Nodes and helps ensure that your channel will perform well on all Roku devices.

### Component Controller

RCL includes a component controller that helps manage the views in your channel. Using the RCL component controller saves you the effort of managing the screen stack on your own.

### Other components

RCL also includes components that make it easier to:

* Use Roku Ad Framework (RAF) to monetize your content
* Use Roku Billing to manage subscriptions and entitlement

## Installation

Follow these steps to prepare your channel to use RCL and its components:

* Copy the `library/RCL` folder into your channel so that the path to the folder is `pkg:/components/RCL`. _This path is required for certain graphic elements to work correctly._
* Copy `library/RCL.brs` into your channel so that the path to the file is `pkg:/source/RCL.brs`
* Add this line to your manifest: `bs_libs_required=roku_ads_lib`

You are now ready to use RCL in your channel!

###### Copyright (c) 2018 Roku, Inc. All rights reserved.
