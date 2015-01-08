express = require 'express'
http = require 'http'
log = require 'npmlog'
fs = require 'fs'
path = require 'path'

module.exports = (options = {}) ->
    app = express()
    app.use express.static __dirname+'/../resources'
    app.set 'log', log

    ###
    Loads conf files in the following order:
        /conf
        /App/conf
        /$model_directory/conf
        /$routes_directory/conf
    ###

    process.argv.shift()
    process.argv.shift()

    for arg in process.argv
        [option, value] = arg.split('?')
        value ?= true
        app.set option, value
        options[option] = value

    for config in ['./conf', './../conf']
        for attr, val of require config
            if attr is 'test'
                if options.testing
                    try options[attr__] = val__ for attr__, val__ of val when attr__ not of options

            else if attr is 'prod'
                if not options.testing
                    try options[attr__] = val__ for attr__, val__ of val when attr__ not of options

            else if attr not of options
                try options[attr] = val

    name = options.name ?= 'App'
    host = options.host ?= '127.0.0.1'
    port = options.port ?= '3000'
    testing = options.testing ?= on

    for dep, option of options.dependencies
        if options.dependencies?
            app.set (option.name ? dep), (option.func ? (x) -> x)((require dep), if options.testing then 'test' else 'prod')

    app.use ware for ware in options.middleware if options.middleware?

    app.set attr, val for attr, val of options when attr isnt 'dependencies' and attr isnt 'middleware' and attr isnt 'Models' and attr isnt 'Routes'

    models = (require "./../models/#{model}" for model in options.models)

    model app for model in models when typeof model is 'function'

    routes = require  './../routes'

    route app for route in routes when typeof route is 'function'

    (app.get 'log').level = 'silent' if options.testing

    http.createServer(app).listen port, host, ->
        log.info (path.basename __filename), "Listening on #{host}:#{port}!"

    app
