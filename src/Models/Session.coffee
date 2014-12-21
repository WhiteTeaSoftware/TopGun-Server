module.exports = (app) ->
    mongoose = app.get 'mongoose'
    
    SessionSchema =
        _id: String
        u: String
        n: String
        t:
            type: Date
            expires: '24h'
            default: Date.now
        
    app.set 'Session', mongoose.model 'sessions', SessionSchema