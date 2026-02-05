_: {
  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
      style = "numbers,changes,header";
      pager = "less -FR";
    };
  };
}
