module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    concat: {
      options: {
        separator: 'rn'
      },
      dist: {
        src: 'synchro_app/synchro/frontend_source/shopify/*.js',
        dest: 'synchro_app/synchro/frontend_build/compiled/synchro_shopify.js'
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
        globals: {
          jQuery: true,
          console: true,
          module: true
        }
      }
    },
    uglify: {
      options: {
        banner: '/*! &lt;%= pkg.name %&gt; &lt;%= grunt.template.today("dd-mm-yyyy") %&gt; */n'
      }, 
      dist: {
        files: {
          'synchro_app/synchro/frontend_build/synchro_shopify.min.js': 'synchro_app/synchro/frontend_build/compiled/synchro_shopify.js'
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

