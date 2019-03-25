# Mite Time Tracking Alfred3 Workflow

An alfred workflow written in Ruby to interact with Mite Time Tracking Tool

![Mite](https://github.com/ciganskovic/mite-alfred3-workflow/mite-logo.png)
[https://mite.yo.lk/](https://mite.yo.lk/)

## Requirements

* Alfred Powerpack License
* Ruby Version > 2.1.0
* Nokogiri

For the installation of ruby i recommend using rvm

The following installation Guide can help

[upgrading-ruby-to-2-1-0-and-above-in-mavericks](https://coderwall.com/p/4imsra/upgrading-ruby-to-2-1-0-and-above-in-mavericks)

## Installation and Setup

1. Install Nokogiri rubygem

```
gem install nokogiri
```

2. Download the mite.workflow file from the worklog directory
3. Enable API Access to your account on **https://<your-mite-domain></your-mite-domain>.mite.yo.lk/myself**
4. After adding the workflow to Alfred run:

```
mt setup <mite-url> <api-key>
```

or

edit the **config.yml** file


## Available commands

* mt setup     # setup your mite account
* mt user      # show information about your Mite account
* mt daily     # show current worklogs of today
* mt projects  # show available projects
* mt services  # show available services
* mt create    # create a new worklog entry
* mt delete    # delete a worklog entry
* mt customers # List Customers
* mt entries   # search for worklogs by keyword or date
* mt tracker   # show running time trackers
* mt modify    # modify a specific time entry
