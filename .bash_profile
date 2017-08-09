export PATH=/Library/PostgreSQL/9.5/bin:$PATH
alias sublpref="subl ~/Library/Application Support/Sublime Text 2/Packages/User/Preferences.sublime-settings"

alias clr="clear"
alias basho="subl ~/.bash_profile"

# GIT COMMANDS
alias ga="git add"
alias gc="git commit"
alias gcom="git commit -m"
# alias gcob="gco master && git checkout -b"
alias gb="git branch"
alias gtv="git remote"
alias gpom="git push origin master"
alias gpu="git pull"
alias gp="git push"
alias gpo="git push origin"
alias gru="git rebase upstream"
alias gm="git merge"
alias gbi="git bisect"
alias gl="git log"
alias gh="git hist"
alias gs="git status"

gco() {
  CURR=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
  echo $CURR
  if [ "$1" == "--prev" ] || [ "$1" == "-p" ]
  then
    if [ -z "$PREV" ]
    then
      echo "No previous branch set"
    else
      git checkout $PREV
      PREV=$CURR
    fi
  else 
    PREV=$CURR
    if [ "$1" == "-b" ]
    then
      git checkout -b $2
    elif [ "$1" == "master" ]
      then
        git checkout master && git pull origin master
    else
        git checkout $1
    fi
  fi
}

gcob() {
  gco master && git pull origin master && gco -b $1
}

gra() {
  git remote add $1 $2
}

gbd_i() {
  takeInput() {
    echo "Delete branch [ "$1" ] ? (y/n)"
    read answer
    if [ "$answer" == "y" ] || [ "$answer" == 'Y' ]
    then
      git branch -D $1
    elif [ "$answer" == "n" ] || [ "$answer" == "N" ]
    then
      echo "Not deleting branch [ "$1" ] ..."
    else
      echo "Please enter either : (y/n)..."
      takeInput $1
    fi
  }

  for br in $(git for-each-ref refs/heads --format='%(refname:short)');
    do
      takeInput $br
    done
}

gbd_() {
  arr=("$@")
  for i in "${arr[@]}";
      do
          git branch -D "$i"
      done
}
gbd() {
  if [ "$1" == "--prev" ] || [ "$1" == "-p" ]
  then
    git branch -D $PREV
  elif [ "$1" == "--interactive" ] || [ "$1" == "-i" ]
  then
    gbd_i
  else
    arr=("$@")
    gbd_ "${arr[@]}"
  fi
}



#
alias proj="cd ~/Desktop/projects"
alias web="proj && cd web"
alias personal="proj && cd personal"


#NPM COMMANDS
alias nins="npm install --save"
alias ni="npm install"
alias nus="npm uninstall --save"
alias nu="npm uninstall"
alias ninit="npm init"

#PSQL COMMANDS
psql() {
  if [ -z "$2" ] 
    then 
      port=5432
    else 
      port=$2
  fi
  "/Applications/Postgres.app/Contents/Versions/9.6/bin/psql" -p$port -d $1
}


#React boilerplate
make-react() {
  mkdir $1 && cd $1
  npm init --y
  nins react react-redux redux \
     react-dom jsx-loader babel-preset-es2015 \
     babel-preset-react babel-core babel-loader \
     redux-thunk underscore \
     webpack webpack-merge \
     react-router react-router-redux \
     express path

  ni --save-dev webpack-dev-server
  build-webpack && cd ..
  build-client && cd ..
  build-server && cd ..
}

build-client() {
  mkdir client && cd client
  mkdir components \
        redux redux/actions redux/reducers

  touch index.html index.jsx routes.jsx \
        redux/actions/types.js redux/actions/index.js \
        redux/reducers/index.js redux/store.js \
        components/App.jsx
}

write-file() {
  echo $2 >> $1
}

build-server() {
  mkdir server && cd server
  mkdir routers config
  touch server.js routes.js routers/index.js
}

build-webpack() {
  mkdir webpack && cd webpack
  touch webpack.common.js webpack.dev.js webpack.prod.js webpack.build.js
  webpack-common
  webpack-dev
  webpack-prod
  webpack-build
}

alias webb="build-webpack"


webpack-common() {
   write-file webpack.common.js \
   "const webpack = require('webpack');

   module.exports = {
  entry: {
    main: './client/index.js'
  }, 

  resolve: {
    extensions: [ '', '.js', '.jsx']
  },

  module: {
    loaders: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015', 'react']
        }
      }
    ]
  },

  //helps separate dependencies out of bundles if you have multiple entry points 
  // plugins: [
  //   new webpack.optimize.CommonsChunkPlugin({
  //     name: ['main']
  //   })
  // ],


  devtool: 'eval'

}"
}

webpack-build() {
  echo \
  "const webpack = require('webpack');
const webpackMerge = require('webpack-merge');
const commonConfig = require('./webpack.common.js');
const path = require('path');


module.exports = webpackMerge(commonConfig, {
  output: {
    path: path.resolve(__dirname, '..', 'client', 'dist'),
    filename: '[name].bundle.js'
  },

  devtool: 'cheap-module-source-map'
})" >> webpack.prod.js
}

webpack-dev() {
  echo \
  "const webpack = require('webpack');
const webpackMerge = require('webpack-merge');
const commonConfig = require('./webpack.common.js');
const path = require('path');


module.exports = webpackMerge(commonConfig, {
  output: {
    path: path.resolve(__dirname, '..'),
    publicPath: '/dist/', 
    filename: '[name].bundle.js'
  },

   devServer: {
    historyApiFallback: true, 
    stats: 'minimal'
  }

});" >> webpack.dev.js
}

webpack-prod() {
  echo \
  "const webpack = require('webpack');
const webpackMerge = require('webpack-merge');
const commonConfig = require('./webpack.common.js');
const path = require('path');


module.exports = webpackMerge(commonConfig, {
  output: {
    path: path.resolve(__dirname, '..', 'client', 'dist'),
    filename: '[name].bundle.js'
  },


  plugins: [
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify('production')
      }
    }),

    new webpack.optimize.UglifyJsPlugin({
      beautify: false,
      mangle: {
        screw_ie8: true,
        keep_fnames: true
      },
      compress: {
          screw_ie8: true
      },
      comments: false
    })
  ],


  devtool: 'cheap-module-source-map'
})" >> webpack.prod.js
}
