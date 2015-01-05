describe 'Message', ->
    tUser =
        u: 'rrdelaney'
        n: 'Ryan'
        p: 'testpass'
        e: 'testemail'

    tUser.t = undefined

    before (done) ->
        mongoose.connection.db.dropDatabase ->
            User.createUser tUser, Response(), (res) ->
                User.findById 'rrdelaney', (err, person) ->
                    User.authenticate {
                        username: 'rrdelaney'
                        code: person.c
                    }, Response(), (res) ->
                        User.login tUser, Response(), (res) ->
                            tUser.t = res.result.t
                            done()

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

        it 'should ignore a bad token'
        it 'should allow a good token'
        it 'should ignore a bad response'
        it 'should allow a good response'

    describe '.getMessage', ->
        it 'should ignore no id'
        it 'should ignore a bad id'
        it 'should allow a good id'

    describe '.getMessages', ->
        it 'should ignore no location'
        it 'should ignore no start time'
