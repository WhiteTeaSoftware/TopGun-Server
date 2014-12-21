module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'
        coffee:
            compile:
                files:
                    'target/test.js': ['src/test.coffee', 'src/Tests/**/*.coffee']
                options:
                    bare: yes
                
            glob_to_multiple:
                expand: yes
                cwd: 'src'
                src: [
                    'app.coffee'
                    'App/**/*.coffee'
                    'Assets/**/*.coffee'
                    'Models/**/*.coffee'
                    'Routes/**/*.coffee'
                ]
                dest: 'target'
                ext: '.js'
                options:
                    bare: yes
                    
        cson:
            glob_to_multiple:
                expand: yes
                cwd: 'src'
                src: ['**/*.cson']
                dest: 'target'
                ext: '.json'
                
        coffeelint:
            app: ['src/**/*.coffee']
            options:
                'max_line_length':
                    'level': 'ignore'
                'indentation':
                    'level': 'ignore'
                'no_throwing_strings':
                    'level': 'ignore'
            
        clean: ['target']
        
        copy:
            main:
                files: [
                    expand: yes
                    cwd: 'src'
                    src: ['**/*.js', '**/*.json', '**/*.html']
                    dest: 'target'
                ]
                
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-cson'
    grunt.loadNpmTasks 'grunt-coffeelint'
    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    
    grunt.registerTask 'default', ['coffeelint', 'clean', 'copy', 'coffee', 'cson']
    
    return