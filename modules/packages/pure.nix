{ pkgs
, ...
}:

{

  programs.zsh = {
    initContent = ''
      zstyle :prompt:pure:git:branch color yellow

      autoload -U promptinit; promptinit
      prompt pure
    '';

    plugins = [
      {
        name = "pure";
        src = "${pkgs.pure-prompt}/share/zsh/site-functions";
      }
    ];
  };

}
