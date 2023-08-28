my Vim config files
===================

::

  mv ~/.vim ~/.vim.old
  git clone https://github.com/lluis/vim_config.git ~/.vim
  cd ~/.vim
  git submodule init
  git submodule update
  cd ~/
  ln -s .vim/.vimrc .
  sudo apt install vim-fugitive

Add a plugin
------------

::

  cd ~/.vim/
  git submodule add https://github.com/pangloss/vim-javascript.git bundle/vim-javascript

Update plugins
--------------

::

  git submodule foreach git pull
  git add bundle

