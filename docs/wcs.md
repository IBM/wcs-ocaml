# Watson Conversation Service command line interface

The compilation produces a command line interface for Watson
Conversation Service in:

```
./_build/install/default/bin/wcs
```

The command line interface support the following commands:
  * `list` - List the workspaces associated with a Conversation service instance.
  * `create` - Create workspaces on the Conversation service instance.
  * `delete` - Delete workspaces from the Conversation service instance.
  * `get` - Get information about workspaces, optionally including all workspace contents.
  * `update` - Update an existing workspace with new or modified data.
  * `try` - Generic bot running in the terminal.


All commands require to get the Watson Conversation Service
credentials. They should be stored in a JSON file with the following
structure
([getting credentials](https://www.ibm.com/watson/developercloud/doc/common/getting-started-credentials.html)):

```js
{
  "url": "https://gateway.watsonplatform.net/conversation/api",
  "password": "PASSWORD",
  "username": "USERNAME"
}
```

The path to this JSON file can be provided either with the option
`-wcs-cred` or through the environment variable `WCS_CRED`.



## The `list` command

List the workspaces associated with a Conversation service instance.

```
Usage:
  wcs list [options]
Options:
  -page_limit n       The number of records to return in each page of results.
  -include_count b    Whether to include information about the number of records returned.
  -sort attr          The attribute by which returned results will be sorted. To reverse the sort order, prefix the value with a minus sign (-). Supported values are name, modified, and workspace_id.
  -cursor token       A token identifying the last value from the previous page of results.
  -short              Display ony workspace ids and names.
  -wcs-cred cred.json The file containing the Watson Conversation Service credentials.
  -version            Print the Watson Conversation API version number used.
  -no-error-recovery  Do not try to recover in case of error.
  -debug              Print debug messages.
  -help               Display this list of options
  ```

The command `ls` is a synonym for the command `list -short`.


## The `create` command

Create workspaces on the Conversation service instance.

```
Usage:
  wcs create [options] [workspace.json ...]
Options:
  -wcs-cred cred.json The file containing the Watson Conversation Service credentials.
  -version            Print the Watson Conversation API version number used.
  -no-error-recovery  Do not try to recover in case of error.
  -debug              Print debug messages.
  -help               Display this list of options
```

## The `delete` command

Delete workspaces from the Conversation service instance.

```
Usage:
  wcs delete [options] [workspace_id ...]
Options:
  -wcs-cred cred.json The file containing the Watson Conversation Service credentials.
  -version            Print the Watson Conversation API version number used.
  -no-error-recovery  Do not try to recover in case of error.
  -debug              Print debug messages.
  -help               Display this list of options
```

The command `rm` is a synonym for the command `delete`.


## The `get` command

Get information about workspaces, optionally including all workspace contents.

```
Usage:
  wcs get [options] [workspace_id ...]
Options:
  -export             To include all element content in the returned data.
  -wcs-cred cred.json The file containing the Watson Conversation Service credentials.
  -version            Print the Watson Conversation API version number used.
  -no-error-recovery  Do not try to recover in case of error.
  -debug              Print debug messages.
  -help               Display this list of options
```

## The `update` command

Update an existing workspace with new or modified data.

```
Usage:
  wcs update [options] workspace.json workspace_id
Options:
  -wcs-cred cred.json The file containing the Watson Conversation Service credentials.
  -version            Print the Watson Conversation API version number used.
  -no-error-recovery  Do not try to recover in case of error.
  -debug              Print debug messages.
  -help               Display this list of options
```

## The `logs` command

List the events from the log of a workspace.

```
Usage:
  wcs logs [options] [workspace_id ...]
Options:
  -filter s           A cacheable parameter that limits the results to those matching the specified filter.
  -page_limit n       The number of records to return in each page of results.
  -sort attr          The attribute by which returned results will be sorted. To reverse the sort order, prefix the value with a minus sign (-). The only supported value is request_timestamp.
  -cursor token       A token identifying the last value from the previous page of results.
  -wcs-cred cred.json The file containing the Watson Conversation Service credentials.
  -version            Print the Watson Conversation API version number used.
  -no-error-recovery  Do not try to recover in case of error.
  -debug              Print debug messages.
  -help               Display this list of options
```


## The `try` command

Generic bot running in the terminal.

```
Usage:
  wcs try [options] workspace_id
Options:
  -context ctx.json   The initial context.
  -text txt           The initial user input.
  -node node_id       The node where to start the conversation.
  -wcs-cred cred.json The file containing the Watson Conversation Service credentials.
  -version            Print the Watson Conversation API version number used.
  -no-error-recovery  Do not try to recover in case of error.
  -debug              Print debug messages.
  -help               Display this list of options
```
