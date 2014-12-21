express = require 'express'
http = require 'http'
log = require 'npmlog'
fs = require 'fs'
path = require 'path'

module.exports = (options = {}) ->
    app = express()
    app.use express.static __dirname+'/../Assets'
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

    try options[attr] = val for attr, val of require './../conf' when attr not of options

    try options[attr] = val for attr, val of require './conf' when attr not of options

    model_directory = options.ModelsDir ? 'Models'
    try options[attr] = val for attr, val of require "./../#{model_directory}/conf" when attr not of options

    route_directory = options.RoutesDir ? 'Routes'
    try options[attr] = val for attr, val of require "./../#{route_directory}/conf" when attr not of options

    name = options.name ?= 'App'
    host = options.host ?= '127.0.0.1'
    port = options.port ?= '3000'

    app.set (option.name ? dep), (option.func ? (x) -> x) require dep for dep, option of options.dependencies if options.dependencies?

    app.use ware for ware in options.middleware if options.middleware?

    app.set attr, val for attr, val of options when attr isnt 'dependencies' and attr isnt 'middleware' and attr isnt 'Models' and attr isnt 'Routes'

    models = (require "./../#{model_directory}/#{model}" for model in options.Models ? fs.readdirSync "#{__dirname}/../#{model_directory}")

    model app for model in models when typeof model is 'function'

    routes = (require "./../#{route_directory}/#{route}" for route in options.Routes ? fs.readdirSync "#{__dirname}/../#{route_directory}")

    route app for route in routes when typeof route is 'function'

    (app.get 'log').level = 'silent' if options.testing

    http.createServer(app).listen port, host, ->
        log.info (path.basename __filename), "Listening on #{host}:#{port}!"

    app
