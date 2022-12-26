import { View, Text } from "react-native";
import React from "react";
import { AntDesign } from "@expo/vector-icons";
import { useNavigation } from "@react-navigation/native";
const HomeHeader = () => {
  const navigation = useNavigation();
  const onSettingsPressed = () => {
    navigation.navigate("Settings");
  };
  const onSearchPressed = () => {
    navigation.navigate("Search");
  };
  return (
    <>
      <AntDesign
        onPress={onSearchPressed}
        name="search1"
        size={24}
        color="white"
        style={{ marginRight: 20 }}
      />
      <AntDesign
        onPress={onSettingsPressed}
        name="setting"
        size={24}
        color="white"
        style={{}}
      />
    </>
  );
};

export default HomeHeader;
