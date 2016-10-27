module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    sass: {
      dist: {
        files: {
          'synchro_app/synchro/css/carousel.css': 'synchro_app/synchro/scss/carousel.scss'
        }
      }
    },
    watch: {
      css: {
        files: '**/*.scss',
        tasks: ['sass']
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.registerTask('default', ['watch'])

  // Run bootstrap's Gruntfile too
  grunt.registerTask('bootstrap', function() {
    var cb = this.async();
    var child = grunt.util.spawn({
        grunt: true,
        args: ['dist'],
        opts: {
            cwd: 'synchro_app/synchro/bootstrap-3.3.7'
        }
    }, function(error, result, code) {
        cb();
    });

    child.stdout.pipe(process.stdout);
    child.stderr.pipe(process.stderr);

  });

}

