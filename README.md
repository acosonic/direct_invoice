# Direct Invoice

Redmine plugin (developed on 3.2.0), per specification by Jan Kocis

  - Sends email with invoice to customer, per single timelog entry
  - Available as per-project module


### Installation

Like standard Redmine plugins:

Navigate to Redmine root installation folder
```sh
$ cd $REDMINE_ROOT
```
Copy plugin source to plugins directory
```sh
$ git clone https://github.com/acosonic/direct_invoice.git plugins/direct_invoice
```
Restart Redmine (if using Passenger)
```sh
$ rm tmp/restart.txt && touch tmp/restart.txt
```
