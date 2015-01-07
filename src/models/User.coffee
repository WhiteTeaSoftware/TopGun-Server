bcrypt = require 'bcrypt-nodejs'
crypto = require 'crypto'
Request = require 'request'
uuid = require 'node-uuid'
path = require 'path'

module.exports = (app) ->
    log = app.get 'log'
    hostUrl = app.get 'url'
    mongoose = app.get 'mongoose'
    sendgrid = app.get 'sendgrid'
    Session = app.get 'Session'

    UserSchema = mongoose.Schema
        _id: String # username
        n: String # display name
        p: String # password
        r: String # remember me token
        c: String # access code
        t: # TTL for
            type: Date
            expires: '14d'
            default: Date.now

    UserSchema.statics.createUser = (options, response, cb=->) ->
        @username = options.u?.toLowerCase()
        @password = options.p
        @display_name = options.n ? options.u
        @email = options.e

        return cb response.status(500).send m: 'Username, password, or email not given' if not @username? or not @password? or not @email?
        try return cb response.status(500).send m: 'Bad username!' for char in app.get 'invalid_chars' when @username.indexOf(char) isnt -1

        bcrypt.hash @password, null, null, (err, hash) =>
            return cb response.status(500).send m: 'Something bad happened server side' if err

            code = crypto.randomBytes(3).toString 'hex'

            user = new @
                _id: @username
                n: @display_name
                p: hash
                c: code

            user.save (err) =>
                return cb response.status(500).send m: 'Username alreay exists!' if err
                cb response.send m: "Verification code sent to #{@email}"

                if not app.get 'testing'
                    sendgrid.send {
                        from: "auth@#{hostUrl}"
                        fromname: 'TopGun App'
                        to: @email
                        toname: @display_name
                        subject: 'Activate your new TopGun account! :D'
                        text: "Your access code is #{code}. Please either enter it into the app or go to #{hostUrl}/auth/#{@username}/#{code}"
                        html: "Your access code is #{code}. Please either enter it into the app or <a href=\"http://#{hostUrl}/auth/#{@username}/#{code}\">click here</a>"
                    }, (err) =>
                        return log.error path.basename(__filename), "Error sending email to #{@email}: %j", err if err

    UserSchema.statics.login = (options, response, cb=->) ->
        @username = options.u?.toLowerCase()
        @password = options.p
        @remToken = options.r
        @oauth_token = options.t
        @user_type = options.y ? 'n'

        nativeLogin = =>
            Session.findOneAndRemove {'u': @username}, =>
                @.findById  @username, (err, user) =>
                    return cb response.status(500).send m: 'Cannot find user!' if not user
                    return cb response.status(500).send m: 'Something bad happened server side' if err
                    return cb response.status(500).send m: 'User is not activated!' if user.c?

                    bcrypt.compare @password, user.p, (err, res) ->
                        return cb response.status(500).send m: 'Something bad happened server side' if err
                        return cb response.status(500).send m: 'Bad login!' if not res

                        sToken = uuid.v4()
                        rToken = uuid.v4()

                        user.r = rToken
                        user.save ->
                            session = new Session
                                _id: sToken
                                u: user._id
                                n: user.n

                            session.save -> cb response.send t: sToken, r: rToken

        rememberMe = =>
            @.findOne {'r': @remToken}, (err, user) ->
                return cb response.status(500).send m: 'Cannot find user!' if not user
                return cb response.status(500).send m: 'Something bad happened server side' if err
                return cb response.status(500).send m: 'User is not activated!' if user.c?

                Session.findOneAndRemove {'u': user.u}, ->
                    sToken = uuid.v4()
                    rToken = uuid.v4()

                    user.r = rToken
                    user.save ->
                        session = new Session
                            _id: sToken
                            u: user._id
                            n: user.n

                        session.save -> cb response.send t: sToken, r: rToken

        nullLogin = ->
            cb response.status(500).send m: 'Bad login!'

        switch
            when @user_type is 'n' and @username? and @password? then nativeLogin()
            when @user_type is 'n' and @remToken? then rememberMe()
            else nullLogin()

    UserSchema.statics.logout = (options, response, cb=->) ->
        @token = options.t

        return cb response.status(500).send m: 'No token!' if not @token?
        Session.findByIdAndRemove @token, (err) ->
            return cb response.status(500).send m: 'Something bad happened server side!' if err
            cb response.send m: 'Done!'

    UserSchema.statics.authenticate = (options, response, cb=->) ->
        @username = options.username.toLowerCase()
        @code = options.code

        @.findById @username, (err, user) =>
            return cb response.status(500).send m: 'Something bad happened server side' if err
            return cb response.status(500).send m: 'No user found matching that username' if user is null
            return cb response.status(500).send m: 'Not the correct code' if user.c isnt @code
            user.c = undefined
            user.t = undefined
            user.save (err) ->
                return cb response.status(500).send m: 'Something bad happened server side' if err
                cb response.send m: 'Done'

    UserSchema.statics.changePassword = (options, response, cb=->) ->
        @username = options.u?.toLowerCase()
        @old_password = options.p
        @new_password = options.np

        return cb response.status(500).send m: 'Username or password not specfied!' if not @username? or not @old_password? or not @new_password?

        @.findById @username, (err, user) =>
                return cb response.status(500).send m: 'Something went wrong server side' if err
                return cb response.status(500).send m: "Could not find user #{@username}" if not user?

                bcrypt.compare @old_password, user.p, (err, res) =>
                    return cb response.status(500).send m: 'Something bad happened server side' if err
                    return cb response.status(500).send m: 'Bad login!' if not res

                    bcrypt.hash @new_password, null, null, (err, hash) ->
                        return cb response.status(500).send m: 'Something bad happened server side' if err

                        user.p = hash
                        user.save -> cb response.send m: "Password updated for #{@username}"

    UserSchema.statics.changeDisplayName = (options, response, cb=->) ->
        @username = options.u?.toLowerCase()
        @password = options.p
        @display_name = options.n

        return cb response.status(500).send m: 'Username or password not specfied!' if not @username? or not @password? or not @display_name?

        @.findById @username, (err, user) =>
            return cb response.status(500).send m: 'Something went wrong server side' if err
            return cb response.status(500).send m: "Could not find user #{@username}" if not user?

            bcrypt.compare @password, user.p, (err, res) =>
                return cb response.status(500).send m: 'Something bad happened server side' if err
                return cb response.status(500).send m: 'Bad login!' if not res

                user.n = @display_name
                user.save -> cb response.send m: "Display name updated for #{@username}"

    app.set 'User', mongoose.model 'users', UserSchema
