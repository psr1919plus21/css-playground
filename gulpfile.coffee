gulp = require("gulp")
coffee = require("gulp-coffee")
watch = require("gulp-watch")
sass = require("gulp-sass")
autoprefixer = require("gulp-autoprefixer")
prettify = require("gulp-prettify")
imagemin = require("gulp-imagemin")
pngquant = require("imagemin-pngquant")
teddy = require("gulp-teddy").settings
  setTemplateRoot: "./src/html"
  compileAtEveryRender: true


path =
  src:
    coffee: "./src/static/coffee/*.coffee"
    sass: "./src/static/sass/*.scss"
    html: ["./src/html/**/*.html","!./src/html/modules/**/*.html"]
    fonts: "./src/static/fonts/*"
    img: "./src/static/img/*"
    imgSvg: "./src/static/img/*.svg"
    imgJpg: "./src/static/img/*.jpg"
    imgPng: "./src/static/img/*.png"
  dist:
    js: "./dist/js/"
    css: "./dist/css/"
    fonts: "./dist/fonts/"
    img: "./dist/img/"

gulp.task "fonts", ->
  gulp.src(path.src.fonts)
  .pipe gulp.dest path.dist.fonts

gulp.task "imagemin", ->
  gulp.src(path.src.img)
  .pipe imagemin
    progressive: true
    svgoPlugins: [{removeViewBox: false}]
    use: [pngquant()]
  .pipe gulp.dest path.dist.img

gulp.task "teddy", ->
  gulp.src(path.src.html)
  .pipe(teddy.compile())
  .pipe gulp.dest "./"

gulp.task "htmluncompress", ["teddy"], ->
  gulp.src("./*.html")
  .pipe prettify({indent_size: 2})
  .pipe gulp.dest("./")

gulp.task "coffee", ->
  gulp.src(path.src.coffee)
  .pipe(do coffee)
  .pipe gulp.dest path.dist.js

gulp.task "sass", ->
  gulp.src(path.src.sass)
  .pipe(do sass)
  .pipe gulp.dest path.dist.css

gulp.task "autoprefixer", ["sass"], ->
  gulp.src("./dist/css/*.css")
  .pipe(do autoprefixer)
  .pipe gulp.dest path.dist.css

gulp.task "watch", ->
  watch path.src.coffee, ->
    gulp.run "coffee"
  watch path.src.sass, ->
    gulp.run "autoprefixer"
  watch path.src.html, ->
    gulp.run "htmluncompress"
  
gulp.task "dev", ["fonts", "imagemin", "coffee", "autoprefixer", "htmluncompress", "watch"], ->

gulp.task "default",  ["fonts", "imagemin", "coffee", "autoprefixer", "htmluncompress"], ->






