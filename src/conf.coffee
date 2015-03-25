exports.env = env = 'test'

exports.prod =
    url: 'localhost'
    host: 'localhost'
    port: '80'
    mongo: 'localhost'
    testing: off

exports.test =
    url: 'localhost'
    host: 'localhost'
    port: '80'
    mongo: 'localhost'

exports.sendgridCredentials =
    username: 'username'
    password: 'password'

exports.name = 'TGServer'
exports.invalid_chars = ['$']
exports.models = [
        'Session'
        'User'
        'Message'
]

exports.middleware = [
        (require 'body-parser').json()
        (req, res, next) ->
            res.setHeader 'Access-Control-Allow-Origin', '*'
            res.setHeader 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE'
            res.setHeader 'Access-Control-Allow-Headers', 'X-Requested-With,Content-Type'
            res.setHeader 'Access-Control-Allow-Credentials', true
            next()
]

exports.dependencies =
        'mongoose':
            func: (mongoose, env) ->
                mongoose.connect "mongodb://#{exports[env].mongo}/TGData", (err) ->
                    (console.log err; process.exit(1)) if err
        'sendgrid':
            func: (sendgrid, env) ->
                sendgrid exports.sendgridCredentials.username, exports.sendgridCredentials.password
