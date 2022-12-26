import { View, Text, TextInput, StyleSheet } from "react-native";
import React from "react";
import { myColors } from "../../../colors";
import { Controller } from "react-hook-form";

const CustomInput = ({
  control,
  name,
  secure,
  rules = {},
  placeholder,
  autoFocus = false,
}) => {
  return (
    <Controller
      control={control}
      name={name}
      render={({
        field: { onChange, onBlur, value },
        fieldState: { error },
      }) => (
        <>
          <View style={[styles.container, error ? styles.container_error : {}]}>
            <TextInput
              autoFocus={autoFocus}
              style={styles.text}
              onBlur={onBlur}
              onChangeText={onChange}
              value={value}
              placeholder={placeholder}
              placeholderTextColor={myColors.inputBoxInsideText}
              secureTextEntry={secure}
            />
          </View>
          {error && (
            <Text style={{ color: "red", alignSelf: "stretch" }}>
              {error.message || "error"}
            </Text>
          )}
        </>
      )}
      rules={rules}
    />
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: myColors.inputBox,
    width: "100%",
    height: 50,
    paddingVertical: 10,
    paddingHorizontal: 20,
    marginVertical: 5,
    marginBottom: 10,
    borderRadius: 5,
  },
  container_error: {
    borderWidth: 1,
    borderColor: "red",
  },

  text: {
    fontSize: 15,
    color: myColors.inputBoxText,
    // fontFamily: "Rubik_400Regular",
  },
});

export default CustomInput;
