module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    concat: {
      options: {
        separator: '\r\n'
      },
      shopify_sdk: {
        src: [
          'synchro_app/synchro/frontend_source/shopify_credentials.js',
          'synchro_app/synchro/frontend_source/shopify_manual/*.js'
        ],
        dest: 'synchro_app/synchro/frontend_build/compiled/synchro.js'
      },
      shopify_buy_button: {
        src: [
          'synchro_app/synchro/frontend_source/shopify_credentials.js',
          'synchro_app/synchro/frontend_source/shopify_buy_button/*.js'
        ],
        dest: 'synchro_app/synchro/frontend_build/compiled/buy_button.js'
      }
    },
    jshint: {
      files: [
        'Gruntfile.js', 
        'synchro_app/synchro/frontend_source/**/*.js', 
        'synchro_app/synchro/frontend_build/compiled/**/*.js'
      ],
      options: {
        laxcomma: true,
        debug: true,
        globals: {
          jQuery: true,
          console: true,
          module: true
        }
      }
    },
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %>; <%= grunt.template.today("dd-mm-yyyy") %> */\n',
        compress: {
          drop_debugger: false
        }
      }, 
      dist: {
        files: {
          'synchro_app/synchro/frontend_build/synchro.min.js': 'synchro_app/synchro/frontend_build/compiled/synchro.js',
          'synchro_app/synchro/frontend_build/buy_button.min.js': 'synchro_app/synchro/frontend_build/compiled/buy_button.js'
        }
      }
    },
    compass: {
      dist: {
        options: {
          sassDir: 'synchro_app/synchro/scss',
          cssDir: 'synchro_app/synchro/css',
          environment: 'development',
          outputStyle: 'compressed'
        }
      }
    },
    watch: {
      files: [
        'Gruntfile.js', 
        'synchro_app/synchro/frontend_source/**/*.js',
        'synchro_app/synchro/scss/**/*.scss'],
      tasks: ['concat', 'uglify', 'jshint', 'compass']
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-compass');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.registerTask('default', ['concat', 'jshint', 'uglify', 'compass', 'watch']);

  // Run bootstrap's Gruntfile too
  grunt.registerTask('bootstrap', function() {
    var cb = this.async();
    var child = grunt.util.spawn({
        grunt: true,
        args: ['dist'],
        opts: {
            cwd: 'synchro_app/synchro/resources/bootstrap'
        }
    }, function(error, result, code) {
        cb();
    });

    child.stdout.pipe(process.stdout);
    child.stderr.pipe(process.stderr);

  });

};

