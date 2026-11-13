{ hostname }:

{
  networking = {
    hostName = hostname;
    computerName = hostname;
    localHostName = hostname;
  };
}
