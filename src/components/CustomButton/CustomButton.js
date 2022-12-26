import { View, Text, StyleSheet, Pressable } from "react-native";
import React from "react";
import { myColors } from "../../../colors";
import { fa_brands_400 } from "../../../assets/fonts/fa_brands_400.ttf";
// import FontAwesome, {
//   SolidIcons,
//   RegularIcons,
//   BrandIcons,
// } from "react-native-fontawesome";

import { FontAwesome } from "@expo/vector-icons";

const CustomButton = ({
  onPress,
  text,
  type = "PRIMARY",
  bgC,
  fgC,
  icon,
  iconColor,
}) => {
  let addSpace = "";
  if (icon) addSpace = "    ";

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) =>
        pressed
          ? [
              styles[`container_pressed_${type}`],
              bgC ? { backgroundColor: bgC } : {},
            ]
          : [styles[`container_${type}`], bgC ? { backgroundColor: bgC } : {}]
      }>
      {({ pressed }) => (
        <Text
          style={[
            pressed
              ? [styles[`text_pressed_${type}`], fgC ? { color: fgC } : {}]
              : [styles[`text_${type}`], fgC ? { color: fgC } : {}],
          ]}>
          <FontAwesome name={icon} size={24} color={iconColor} />
          {addSpace}
          {text}
        </Text>
      )}
    </Pressable>
  );
};

const styles = StyleSheet.create({
  container_PRIMARY: {
    backgroundColor: myColors.primaryBtn,
    width: "100%",
    alignItems: "center",
    padding: 15,
    marginVertical: 5,
    borderRadius: 5,
  },
  container_pressed_PRIMARY: {
    backgroundColor: myColors.primaryBtnPressed,
    width: "100%",
    alignItems: "center",
    padding: 15,
    marginVertical: 5,
    borderRadius: 5,
  },
  container_SECONDARY: {
    // borderWidth: 2,
    backgroundColor: "#00000080",
    width: "100%",
    alignItems: "center",
    padding: 15,
    marginVertical: 5,
    // borderRadius: 5,
    // borderColor: myColors.primaryBtn,
  },
  container_pressed_SECONDARY: {
    backgroundColor: myColors.secondaryBtnPressed,
    width: "100%",
    alignItems: "center",
    padding: 15,
    marginVertical: 5,
    borderRadius: 5,
  },
  text_PRIMARY: {
    fontWeight: "bold",
    color: myColors.primaryBtnText,
    fontSize: 15,
    // fontFamily: "Rubik",
  },
  text_pressed_PRIMARY: {
    fontWeight: "bold",
    color: myColors.primaryBtnTextPressed,
    fontSize: 15,
  },
  text_SECONDARY: {
    fontWeight: "bold",
    color: myColors.secondaryBtnText,
    fontSize: 15,
    // fontFamily: "Rubik",
  },
  text_pressed_SECONDARY: {
    fontWeight: "bold",
    color: myColors.secondaryBtnTextPressed,
    fontSize: 15,
  },
});

export default CustomButton;
