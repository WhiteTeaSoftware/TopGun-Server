describe 'User', ->
    before (done) ->
        mongoose.connection.db.dropDatabase done

    describe '.createUser', ->
        it 'should ignore bad usernames', (done) ->
            User.createUser {
                u: '$badUser'
                n: 'Bad User'
                p: 'testpass'
                e: 'testemail'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                User.findById '$badUser', (err, person) ->
                    expect(err, 'err').to.be.null
                    expect(person, 'User').to.be.null
                    done()

        it 'should ignore no username', (done) ->
            User.createUser {
                n: 'Ryan'
                p: 'testpass'
                e: 'testemail'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                User.findById 'ryan', (err, person) ->
                    expect(err, 'err').to.be.null
                    expect(person, 'User').to.be.null
                    done()

        it 'should ignore no password', (done) ->
            User.createUser {
                u: 'ryan'
                n: 'Ryan'
                e: 'testemail'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                User.findById 'ryan', (err, person) ->
                    expect(err, 'err').to.be.null
                    expect(person, 'User').to.be.null
                    done()

        it 'should ignore no email', (done) ->
            User.createUser {
                u: 'ryan'
                n: 'Ryan'
                p: 'testpass'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                User.findById 'ryan', (err, person) ->
                    expect(err).to.be.null
                    expect(person).to.be.null
                    done()

        it 'should add a good user', (done) ->
            User.createUser {
                u: 'ryan'
                n: 'Ryan'
                p: 'testpass'
                e: 'testemail@example.com'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 200
                User.findById 'ryan', (err, person) ->
                    expect(err, 'err').to.be.null
                    expect(person, 'User').to.not.be.null
                    expect(person._id, 'User._id').to.equal 'ryan'
                    expect(person.n, 'User.n').to.equal 'Ryan'
                    expect(person.p, 'User.p').to.not.equal 'testpass'
                    expect(person.c, 'User.c').to.have.length 6
                    done()

    describe '.authenticate', ->
        it 'should ignore bad users', (done) ->
            User.authenticate {
                username: 'baduser'
                code: 'badcod'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                done()

        it 'should ignore bad codes', (done) ->
            User.findById 'ryan', (err, person) ->
                expect(err, 'err_1').to.be.null
                expect(person, 'User_1').to.not.be.null
                User.authenticate {
                    username: 'ryan'
                    code: 'badcod'
                }, Response(), (res) ->
                    expect(res.code, 'Response.code').to.equal 500
                    User.findById 'ryan', (err, _person) ->
                        expect(err, 'err_2').to.be.null
                        expect(_person.code, 'User_2.c').to.equal(person.code)
                        done()

        it 'should allow good username/code combinations', (done) ->
            User.findById 'ryan', (err, person) ->
                expect(err, 'err_1').to.be.null
                expect(person, 'User_1').to.not.be.null
                expect(person.c, 'User_1.c').to.not.be.null
                User.authenticate {
                    username: 'ryan'
                    code: person.c
                }, Response(), (res) ->
                    expect(res.code, 'Response.code').to.equal 200
                    User.findById 'ryan', (err, _person) ->
                        expect(err, 'err_2').to.be.null
                        expect(_person, 'User_2').to.not.be.null
                        expect(_person.c, 'User_2.c').to.be.undefined
                        done()

    describe '.login', ->
        it 'should ignore no username', (done) ->
            User.login {
                p: 'testpass'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                Session.find {u: 'ryan'}, (err, sessions) ->
                    expect(err, 'err').to.be.null
                    expect(sessions, 'sessions').to.be.empty
                    done()

        it 'should ignore no password for native', (done) ->
            User.login {
                u: 'ryan'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                Session.find {u: 'ryan'}, (err, sessions) ->
                    expect(err, 'err').to.be.null
                    expect(sessions, 'sessions').to.be.empty
                    done()

        it 'should accept valid logins', (done) ->
            User.login {
                u: 'ryan'
                p: 'testpass'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 200
                expect(res.result, 'Response.result').to.not.be.empty
                expect(res.result.t, 'Token').to.not.be.undefined
                Session.find {u: 'ryan'}, (err, sessions) ->
                    expect(err, 'err').to.be.null
                    expect(sessions, 'sessions').to.not.be.empty
                    expect(sessions, 'sessions').to.have.length 1
                    expect(sessions[0], 'Session').to.not.be.undefined
                    expect(sessions[0].u, 'Session.u').to.equal 'ryan'
                    expect(sessions[0].n, 'Session.n').to.equal 'Ryan'
                    expect(sessions[0]._id, 'Session._id').to.equal res.result.t
                    done()

        it 'should ignore bad remember me logins', (done) ->
            User.login {
                u: 'ryan'
                p: 'testpass'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 200
                expect(res.result, 'Response.result').to.not.be.empty
                expect(res.result.r, 'rToken').to.not.be.undefined
                User.login {
                    r: 'badremtoken'
                }, Response(), (res) ->
                    expect(res.code, 'Response_1.code').to.equal 500
                    expect(res.result, 'Response_1.result').to.not.be.empty
                    expect(res.result.t, 'Token').to.be.undefined
                    done()

        it 'should allow remember me logins', (done) ->
            User.login {
                u: 'ryan'
                p: 'testpass'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 200
                expect(res.result, 'Response.result').to.not.be.empty
                expect(res.result.r, 'rToken').to.not.be.undefined
                User.login {
                    r: res.result.r
                }, Response(), (res) ->
                    expect(res.code, 'Response_1.code').to.equal 200
                    expect(res.result, 'Response_1.result').to.not.be.empty
                    expect(res.result.t, 'Token').to.not.be.undefined
                    Session.findById res.result.t, (err, session) ->
                        expect(err, 'err').to.be.null
                        expect(session, 'Session').to.not.be.undefined
                        expect(session.u, 'Session.u').to.equal 'ryan'
                        expect(session.n, 'Session.n').to.equal 'Ryan'
                        expect(session._id, 'Session._id').to.equal res.result.t
                        done()


    describe '.logout', ->
        it 'should ignore no token', (done) ->
            User.logout {}, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                done()

        it 'should ignore invalid tokens', (done) ->
            User.logout {t: 'badtoken'}, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 200
                Session.find {u: 'ryan'}, (err, sessions) ->
                    expect(err, 'err').to.be.null
                    expect(sessions, 'sessions').to.not.be.empty
                    done()

        it 'should logout good tokens', (done) ->
            Session.find {u: 'ryan'}, (err, sessions) ->
                expect(err, 'err_1').to.be.null
                expect(sessions, 'sessions').to.not.be.empty
                User.logout {
                    t: sessions[0].t
                }, Response(), (res) ->
                    expect(res.code, 'Response.code').to.equal 200
                    Session.findById sessions[0].t, (err, session) ->
                        expect(err, 'err_2').to.be.null
                        expect(err, 'session').to.be.null
                        done()

    describe '.changeDisplayName', ->
        it 'should ignore no username', (done) ->
            User.changeDisplayName {
                p: 'testpass'
                n: 'Big D'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                done()

        it 'should ignore no password', (done) ->
            User.changeDisplayName {
                u: 'ryan'
                n: 'Big D'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                done()

        it 'should ignore no new name', (done) ->
            User.changeDisplayName {
                u: 'ryan'
                p: 'testpass'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                done()

        it 'shouldnt work for bad usernames', (done) ->
            User.changeDisplayName {
                u: 'bob'
                p: 'nopass'
                n: 'BOB'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                done()

        it 'shouldnt work for bad logins', (done) ->
            User.changeDisplayName {
                u: 'ryan'
                p: 'badpass'
                n: 'Big D'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                User.findById 'ryan', (err, user) ->
                    expect(err, 'err').to.be.null
                    expect(user, 'User').to.not.be.null
                    expect(user.n, 'User.n').to.equal 'Ryan'
                    done()

        it 'should work for good logins', (done) ->
            User.changeDisplayName {
                u: 'ryan'
                p: 'testpass'
                n: 'Big D'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 200
                User.findById 'ryan', (err, user) ->
                    expect(err, 'err').to.be.null
                    expect(user, 'User').to.not.be.null
                    expect(user.n, 'User.n').to.equal 'Big D'
                    done()

    describe '.changePassword', ->
        it 'should ignore no username', (done) ->
            User.changePassword {
                p: 'testpass'
                np: 'newpass'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                done()

        it 'should ignore no password', (done) ->
            User.changePassword {
                u: 'ryan'
                np: 'newpass'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                done()

        it 'should ignore no new password', (done) ->
            User.changePassword {
                u: 'ryan'
                np: 'newpass'
            }, Response(), (res) ->
                expect(res.code, 'Response.code').to.equal 500
                done()

        it 'should ignore bad passwords', (done) ->
            User.changePassword {
                u: 'ryan'
                p: 'badpass'
                np: 'newpass'
            }, Response(), (res) ->
                expect(res.code, 'Response_1.code').to.equal 500
                User.login {
                    u: 'ryan'
                    p: 'testpass'
                }, Response(), (res) ->
                    expect(res.code, 'Response_2.code').to.equal 200
                    User.login {
                        u: 'ryan'
                        p: 'newpass'
                    }, Response(), (res) ->
                        expect(res.code, 'Response_3.code').to.equal 500
                        done()

        it 'should allow good passwords', (done) ->
            User.changePassword {
                u: 'ryan'
                p: 'testpass'
                np: 'newpass'
            }, Response(), (res) ->
                expect(res.code, 'Response_1.code').to.equal 200
                User.login {
                    u: 'ryan'
                    p: 'testpass'
                }, Response(), (res) ->
                    expect(res.code, 'Response_2.code').to.equal 500
                    User.login {
                        u: 'ryan'
                        p: 'newpass'
                    }, Response(), (res) ->
                        expect(res.code, 'Response_3.code').to.equal 200
                        done()
