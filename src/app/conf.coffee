try
    uSettings = require './../conf'
catch
    console.log 'No src/conf.cson found!'
    exit 1

module.exports =
    name: 'TGServer'
    invalid_chars: ['$']
    models: [
        'Session'
        'User'
        'Message'
    ]
    middleware: [
        (require 'body-parser').json()
        (req, res, next) ->
            res.setHeader 'Access-Control-Allow-Origin', '*'
            res.setHeader 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE'
            res.setHeader 'Access-Control-Allow-Headers', 'X-Requested-With,Content-Type'
            res.setHeader 'Access-Control-Allow-Credentials', true
            next()
    ]
    dependencies:
        'mongoose':
            func: (mongoose, env) ->
                mongoose.connect "mongodb://#{uSettings[env].mongo}/TGData", (err) ->
                    (console.log err; process.exit(1)) if err
        'sendgrid':
            func: (sendgrid, env) ->
                sendgrid uSettings.sendgridCredentials.username, uSettings.sendgridCredentials.password
