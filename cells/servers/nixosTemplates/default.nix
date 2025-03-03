{
  inputs,
  cell,
}:
inputs.haumea.lib.load {
  inputs = {
    inherit inputs cell;
  };
  src = ./.;
}
