module.exports = (app) ->
    mongoose = app.get 'mongoose'
    log = app.get 'log'
    Session = app.get 'Session'
    User = app.get 'User'

    ResponseSchema = mongoose.Schema
        u: String # username
        n: String # display name
        v: String # text

    MessageSchema = mongoose.Schema
        u: String # username
        n: String # display name
        v: String # text
        l: [] # location
        r: [ResponseSchema]
        t: # time of creation
            type: Date
            default: Date.now

    MessageSchema.index
        l: '2dsphere'

    MessageSchema.statics.postMessage = (options, response, cb=->) ->
        @token = options.t
        @text = options.v
        @location = options.l
        @response = options.r

        return cb response.status(500).send m: "Either token or text wasn't specified" if not @token? or not @text?

        query = Session
                .findById @token
                .select 'u n -_id'
                .lean()

        query.exec (err, session) =>
            return cb response.status(500).send m: 'Some error happened server side!' if err
            return cb response.status(500).send m: 'Bad token!' if not session?

            @username = session.u
            @display_name = session.n

            if not @response?
                message = new @
                    u: @username
                    n: @display_name
                    v: @text
                    l: @location

                message.save (err) =>
                    if err
                        log.warn path.basename(__filename), "A message from user #{@username} was not saved..."
                        log.warn path.basename(__filename), 'Error: %j', err
                        cb response.status(500).send m: 'Something bad happened server side'
                    else
                        cb response.send m: 'Transaction completed'

            else
                query = @.findById @response
                query.exec (err, message) =>
                    return cb response.status(500).send m: 'Something bad happened server side' if err
                    return cb response.status(500).send m: 'Message not found' if not message?
                    message.r.push
                        u: @username
                        n: @display_name
                        v: @text

                    message.save (err) ->
                        if err then cb response.status(500).send m: 'Something bad happened server side' else response.send m: 'Transaction completed'

    MessageSchema.statics.getMessage = (options, response) ->
        @_id = options._id

        return response.status(500).send m: 'Message id not specified!' if not @_id?

        query = @.findById(@_id)
                .select 'u v n r'
                .lean()

        query.exec (err, message) ->
            return response.status(500).send m: 'Something bad happened server side!' if err
            return response.status(500).send m: 'Message could not be found!' if not message?
            response.send message

    MessageSchema.statics.getMessages = (options, response) ->
        @location = options.l
        @timeStart = new Date options.s
        @timeEnd = if options.e? then new Date options.e else Date.now()

        return response.status(500).send m: "Either location or timeStart wasn't specified" if not @location?

        query = @.find()
                .circle 'l',
                    center: @location
                    radius: .0005 # Units in radians, convert to degrees, multiply by 111.12 to get kilometers, then convert to miles.
                    spherical: yes
                .where('t').gt(@timeStart).lte(@timeEnd)
                .sort 't': 'desc'
                .select 'u v n r'
                .lean()

        query.exec (err, messages) ->
            if err
                log.error path.basename(__filename), 'Some error happened while finding messages'
                log.error path.basename(__filename), 'Error: %j', err
                response.status 500 .send m: 'Some error happened server side!'

            else
                response.send messages

    app.set 'Message', mongoose.model 'messages', MessageSchema
