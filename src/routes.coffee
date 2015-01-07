module.exports = (app) ->
    Message = app.get 'Message'
    User = app.get 'User'
    
    app.post '/getMessages', (req, res) -> Message.getMessages req.body, res
    app.post '/getMessage', (req, res) -> Message.getMessage req.body, res
    app.get '/getMessage/:_id', (req, res) -> Message.getMessage req.params, res
    app.post '/postMessage', (req, res) -> Message.postMessage req.body, res
    app.post '/createUser', (req, res) -> User.createUser req.body, res
    app.post '/login', (req, res) -> User.login req.body, res
    app.post '/logout', (req, res) -> User.logout req.body, res
    app.post '/changePassword', (req, res) -> User.changePassword req.body, res
    app.post '/changeDisplayName', (req, res) -> User.changeDisplayName req.body, res
    app.get '/auth/:username/:code', (req, res) -> User.authenticate req.params, res