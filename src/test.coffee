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

app = (require './App/App')(
    testing: on
    host: process.env.HOST ? process.env.npm_package_config_test_host
    port: process.env.PORT ? process.env.npm_package_config_test_port
    dependencies:
        'mongoose':
            func: (mongoose) ->
                mongoose.connect "mongodb://#{process.env.MONGO ? process.env.npm_package_config_test_mongo}/TGTestData", (err) ->
                    (console.log err; process.exit(1)) if err

        'sendgrid':
            func: (sendgrid) ->
                sendgrid process.env.SENDGRID_USERNAME ? process.env.npm_package_config_sendgrid_username, process.env.SENDGRID_PASSWORD ? process.env.npm_package_config_sendgrid_password
)

Session = app.get 'Session'
mongoose = app.get 'mongoose'
User = app.get 'User'
Session = app.get 'Session'
