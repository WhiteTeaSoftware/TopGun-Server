module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'
        coffee:
            test:
                files:
                    'target/test/test.js': ['test/test.coffee', 'test/**/*.spec.coffee']
                options:
                    bare: yes

            dist:
                expand: yes
                cwd: 'src'
                src: [
                    'server.coffee'
                    'routes.coffee'
                    'app/**/*.coffee'
                    'models/**/*.coffee'
                ]
                dest: 'target'
                ext: '.js'
                options:
                    bare: yes

        cson:
            dist:
                expand: yes
                cwd: 'src'
                src: ['**/*.cson', '!*.template.cson']
                dest: 'target'
                ext: '.json'

        coffeelint:
            dist: ['src/**/*.coffee']
            options:
                'max_line_length':
                    'level': 'ignore'
                'indentation':
                    'level': 'ignore'
                'no_throwing_strings':
                    'level': 'ignore'

        clean: ['target']

        copy:
            dist:
                files: [
                    {
                        expand: yes
                        cwd: 'src'
                        src: ['**/*.js', '**/*.json']
                        dest: 'target'
                    },{
                        expand: yes
                        cwd: 'resources'
                        src: ['*']
                        dest: 'target/resources'
                    }
                ]

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-cson'
    grunt.loadNpmTasks 'grunt-coffeelint'
    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-copy'

    grunt.registerTask 'default', ['coffeelint', 'clean', 'copy', 'coffee', 'cson']

    return
