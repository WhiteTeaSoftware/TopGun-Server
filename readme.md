# TopGun Server

## Building

### Setup

To build TG Server, you'll need a few tools: grunt-cli, coffee-script and mocha.
Install these with

    npm install -g grunt-cli mocha

Next thing you'll want to do is clone the git repo and change to the directory.

    git clone https://github.com/rrdelaney/TopGun-Server.git
    cd TopGun-Server

Now you're ready to build!

### The Build

First install all of the dependencies for TG Server

    npm install

And build the source

    grunt

Set the IP to whatever you need, same for the port.
To test everything and make sure it's working, run

    npm test

Please note if any tests fail. You can now run the server with

    npm start

## Conventions

So TG uses a few conventions for sending information and naming things.
First off, `token` is a users code to access TG. `access_token` is an oauth
token used for logging in with oauth. Both are represented by `t` in data
transfers. `username` is like a screen name, but with spaces. It can pretty much
be anything the user wants. If the user logs in with Facebook, their Facebook
username is used. This is represented by `u`. `text` is the message a user
writes. Represented by `v`. `usertype` is the type of login a user is
requesting. If left blank, it is assumed to be native login. Otherwise,
`fb` specifies a Facebook login and `t` specifies a Twitter login. Twitter
is not yet supported. This is represented by `y`. `location` is an array of two
numbers, latitude and longitude. This is specified by `l`. `startTime` is a
time specified to start looking for. It can be specified as an Number in Unix
time or along the format of `August 1, 2014 08:00:00`. This is represented by
`s`. If an `endTime` is specified in the same fashion, it is represented by `e`.
Finally, a user's `password` is represented by `p`. `r` is `response`. It can
designate what message is being responded to, or what the responses are.

TL;DR

    | Symbol | Meaning        |
    | ------ | -------------- |
    | u      | Username       |
    | n      | Display Name   |
    | p      | Password       |
    | t      | Token          |
    | v      | Text           |
    | y      | Usertype       |
    | l      | Location       |
    | s      | StartTime      |
    | e      | EndTime        |
    | m      | Server Message |
    | r      | Response       |
    | np     | New Password   |
    | _id    | Message ID     |

## POSTing

All responses are in the form of

    {
        "m": "Message about whatever happened"
    }

or

    {
        "t": $access_token
    }

or

    [
        {
            "_id": "$unique_message_id",
            "u": "Guy",
            "n": "Francisco Guadalupe"
            "l": [10, 30],
            "v": "This is an example message",
            "r": []
        },
        {
            "_id": "$unique_message_id",
            "u": "OtherGuy",
            "n": "Imma be",
            "l": [15, 30],
            "v": "This is some other example message",
            "r": []
        }
    ]

or

    [
        {
            "_id": "$unique_message_id",
            "u": "Guy",
            "n": "Puff the Magic Dragon",
            "l": [10, 30],
            "v": "This is an example message",
            "r": [
                {
                    "_id": "$unique_message_id",
                    "u": "other_guy",
                    "n": "Other Guy",
                    "v": "Some response text"
                }
            ]
        }
    ]

The first occurs on everything that isn't login or getMessages. The second
happens on login, where `$access_token` is the account's access token. The
last happens on getMessages.

### /postMessage

When you want to post a message, send something like this

    {
        "t": "aaa-aaa-aaa",
        "v": "Ahoy!",
        "l": [-1.234544, 2.777899]
    }

and it will get thrown into MongoDB. Note that your access token contains
information about your user id!

To response to a message, add an attribute `r` with a value of the message
id you want to respond to. Note that responses don't need locations.

### /getMessage

To get a single message, send

    {
        "_id": "$MESSAGE_ID"
    }

and you'll get something back like

    {
        "_id": "$MESSAGE_ID",
        "u": "OtherGuy",
        "n": "JayZ",
        "l": [15, 30],
        "v": "This is some other example message",
        "r": []
    }

Alternatively, you can GET the message, with

    /getMessage/$MESSAGE_ID

### /getMessages

When you want a list of recent messages, send something like this

    {
        "l": [-1.234544, 2.777899],
        "s": "August 1, 2014 08:00:00"

    }

you can also add an attribute `e` which specifies a time to stop looking for
messages.

and you'll get something like

    [
        {
            "_id": "$unique_message_id",
            "u": "Guy",
            "n": "Francisco Guadalupe"
            "l": [10, 30],
            "v": "This is an example message",
            "r": []
        },
        {
            "_id": "$unique_message_id",
            "u": "OtherGuy",
            "n": "JayZ",
            "l": [15, 30],
            "v": "This is some other example message",
            "r": []
        }
    ]

### /login

#### Native Accounts

POST something like

    {
        "u": "ryan",
        "p": "aaaa",
    }

and you'll get an access token as a response. That token will be valid for
24 hours. If you don't specify a usertype, it will be assumed that it's native.
You can specify native though by setting `"y": "n"`.

#### Facebook

POST this

    {
        "t": "$fb_access_token",
        "y": "fb"
    }

replacing `$fb_access_token` with the real deal and you'll get an access token
valid for 24 hours.

### /createUser

POST something like

    {
        "u": "ryan",
        "n": "Ryan Delaney",
        "p": "aaaa",
        "e": "something@gmail.com"
    }

to create a user. Follow the link in the email to authenticate.

### /auth

So say you create a user, `ryan`, and they're given a token `XXXXXX`.
To authenticate that user do

    GET http://host:port/auth/ryan/XXXXXX

### /changePassword

To change the password of user `ryan`, with a password of `XXXXX`, to `YYYYYY`,
send a POST like

    {
        "u": "ryan",
        "p": "XXXXXX",
        "np": "YYYYYY"
    }

### /changeDisplayName

To change the display name of user `ryan`, with a password of `XXXXX`, to
`Ryan Delaney`, send a POST like

    {
        "u": "ryan",
        "p": "XXXXXX",
        "n": "Ryan Delaney"
    }
