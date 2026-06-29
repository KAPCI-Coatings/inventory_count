enum SettingsOption { inventory, asset, rawMaterial }

class SettingsState {
  final SettingsOption selectedOption;
  const SettingsState({this.selectedOption = SettingsOption.inventory});
}
