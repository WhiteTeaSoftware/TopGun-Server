describe 'Message', ->
    tUser =
        u: 'rrdelaney'
        n: 'Ryan'
        p: 'testpass'
        e: 'testemail'

    tUser.t = undefined

    before (done) ->
        addUser = ->
            User.createUser tUser, Response(), (res) ->
                User.findById 'rrdelaney', (err, person) ->
                    User.authenticate {
                        username: 'rrdelaney'
                        code: person.c
                    }, Response(), (res) ->
                        User.login tUser, Response(), (res) ->
                            tUser.t = res.result.t
                            done()

        if mongoose.connection.readyState is 1
            mongoose.connection.db.dropDatabase addUser
        else
            mongoose.connection.on 'connected', ->
                mongoose.connection.db.dropDatabase addUser

    describe '.postMessage', ->
        it 'should ignore no token', (done) ->
            Message.postMessage {
                v: 'Sample text'
                l: [10, 30]
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                Message.find {
                    v: 'Sample text'
                }, (err, messages) ->
                    expect(err, 'err').to.be.null
                    expect(messages, 'Messages').to.be.empty
                    done()

        it 'should ignore no text', (done) ->
            Message.postMessage {
                t: tUser.t
                l: [10, 30]
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                Message.find {
                    u: tUser.u
                }, (err, messages) ->
                    expect(err, 'err').to.be.null
                    expect(messages, 'Messages').to.be.empty
                    done()

        it 'should ignore a bad token', (done) ->
            Message.postMessage {
                t: 'badToken'
                l: [10, 30]
                v: 'Bad text for bad token'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                Message.find {
                    v: 'Bad text for bad token'
                }, (err, messages) ->
                    expect(err, 'err').to.be.null
                    expect(messages, 'Messages').to.be.empty
                    done()

        it 'should allow a good token', (done) ->
            Message.postMessage {
                t: tUser.t
                l: [10, 30]
                v: 'Good sample text'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 200
                Message.find {
                    u: tUser.u
                }, (err, messages) ->
                    expect(err, 'err').to.be.null
                    expect(messages, 'Messages').to.not.be.empty
                    expect(messages, 'Messages').to.have.length 1
                    expect(messages[0].v, 'Messages[0].v').to.equal 'Good sample text'
                    done()

        it 'should ignore a bad response', (done) ->
            Message.find {
                u: tUser.u
            }, (err, messages) ->
                expect(err, 'err1').to.be.null
                expect(messages, 'Messages1').to.not.be.empty
                expect(messages, 'Messages1').to.have.length 1
                expect(messages[0].v, 'Messages[0].v').to.equal 'Good sample text'
                message_id = messages[0]._id
                Message.postMessage {
                    t: tUser.t
                    v: 'Bad response text'
                    r: 'not really an id'
                }, Response(), (res) ->
                    expect(res.code, 'Response.code').to.equal 500
                    Message.find {
                        _id: message_id
                    }, (err, messages) ->
                        expect(err, 'err2').to.be.null
                        expect(messages, 'Messages2').to.have.length 1
                        expect(messages[0].r, 'Messages[0].r').to.be.empty
                        done()

        it 'should allow a good response', (done) ->
            Message.find {
                u: tUser.u
            }, (err, messages) ->
                expect(err, 'err1').to.be.null
                expect(messages, 'Messages1').to.not.be.empty
                expect(messages, 'Messages1').to.have.length 1
                expect(messages[0].v, 'Messages[0].v').to.equal 'Good sample text'
                message_id = messages[0]._id
                Message.postMessage {
                    t: tUser.t
                    v: 'Good response text'
                    r: message_id
                }, Response(), (res) ->
                    expect(res.code, 'Response.code').to.equal 200
                    Message.find {
                        _id: message_id
                    }, (err, messages) ->
                        expect(err, 'err2').to.be.null
                        expect(messages, 'Messages2').to.have.length 1
                        expect(messages[0].r, 'Messages[0].r').to.have.length 1
                        expect(messages[0].r[0].v).to.equal 'Good response text'
                        done()

    describe '.getMessage', ->
        it 'should ignore no id'
        it 'should ignore a bad id'
        it 'should allow a good id'

    describe '.getMessages', ->
        it 'should ignore no location'
        it 'should ignore no start time'
