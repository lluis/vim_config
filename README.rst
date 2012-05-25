my Vim config files
===================

::

  mv ~/.vim ~/.vim.old
  git clone git://github.com/lluis/vim_config.git ~/.vim
  cd ~/.vim
  git submodule init
  git submodule update
  cd ~/
  ln -s .vim/.vimrc .


