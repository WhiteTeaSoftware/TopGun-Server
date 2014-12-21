module.exports =
    name: 'TGServer'
    host: process.env.HOST ? process.env.npm_package_config_prod_host
    port: process.env.PORT ? process.env.npm_package_config_prod_port
    hostUrl: 'localhost'
    invalid_chars: ['$']
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
            func: (mongoose) ->
                mongoose.connect "mongodb://#{process.env.MONGO ? process.env.npm_package_config_prod_mongo}/TGData", (err) ->
                    (console.log err; process.exit(1)) if err
        'sendgrid':
            func: (sendgrid) ->
                sendgrid process.env.npm_package_config_email_username, process.env.npm_package_config_email_password
