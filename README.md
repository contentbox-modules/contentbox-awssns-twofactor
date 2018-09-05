# AWS SNS Two Factor Authentication Provider for ContentBox

This module will enhance your ContentBox installation with a two-factor provider that leverages AWS SNS.

## Requirements

* Lucee 5+
* Adobe ColdFusion11+

## Test Suite

In order to hack away at this module you will need to have CommandBox CLI installed along side the following core modules: `commandbox-dotenv, commandbox-cfconfig`.  You can install them globally easily:

```bash
box install commandbox-dotenv,commandbox-cfconfig
```

### DataBase

Since ContentBox is a database driven application, it will require for you to have a test database in your system. MySQL is what we use for testing purposes.


### Installing Dependencies & Starting Server

Once installed go into the `test-harness` and into the `box` shell. You will then install the project dependencies and choose which target CFML engine to test on. Available test engines are:

- `server-adobe@11.json`
- `server-adobe@2016.json`
- `server-adobe@2018.json`
- `server-lucee@5.json`

```bash
# install dependencies
install
# startup engine
server start serverConfigFile=server-lucee@5.json
```

This will startup the engine and create a datasource connection for you so you work with the project.