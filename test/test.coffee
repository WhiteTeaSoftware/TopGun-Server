Response = ->
    code: 200
    result: {}
    status: (status) ->
        @code = status
        @

    send: (message) ->
        @result = message
        @

Request = require 'request'
expect = (require 'chai').expect

app = (require './../app/app')(
    testing: on
)

mongoose = app.get 'mongoose'
User = app.get 'User'
Message = app.get 'Message'
Session = app.get 'Session'
