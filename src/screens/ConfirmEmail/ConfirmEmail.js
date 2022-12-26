import {
  View,
  Alert,
  Text,
  StyleSheet,
  useWindowDimensions,
} from "react-native";
import React, { useState } from "react";
import CustomInput from "../../components/CustomInput/CustomInput";
import CustomButton from "../../components/CustomButton";
import { myColors } from "../../../colors";
import SocialSignInButtons from "../../components/SocialSignInButtons";
import { useNavigation } from "@react-navigation/native";
import { useForm } from "react-hook-form";
import { useRoute } from "@react-navigation/native";

const ConfirmEmail = () => {
  const route = useRoute();
  const { control, handleSubmit, watch } = useForm({
    defaultValues: {
      email: route?.params?.email,
    },
  });

  const email = watch("email");
  const navigation = useNavigation();

  const onConfirmPressed = async (data) => {
    try {
      const response = await Auth.confirmSignUp(data.email, data.code);
      navigation.popToTop();
    } catch (error) {
      Alert.alert("Oops", error.message);
    }
  };

  const onResendPressed = async () => {
    try {
      const response = await Auth.resendSignUp(email);
      Alert.alert("Success", "Code resent");
    } catch (error) {
      Alert.alert("Oops", error.message);
    }
  };
  const onSignInPressed = () => {
    console.warn("Sign in");
    navigation.navigate("SignIn");
  };

  const { width, height } = useWindowDimensions();
  const [Code, setCode] = useState("");
  const [ConfirmPassword, setConfirmPassword] = useState("");
  return (
    <View style={styles.root}>
      <Text style={styles.title}>Confirm your email</Text>
      <View style={styles.container}>
        <CustomInput
          name="email"
          placeholder="Email"
          control={control}
          rules={{ required: "Email is required" }}
        />
        <CustomInput
          name="code"
          placeholder="Enter your confirmation code"
          control={control}
          rules={{ required: "Confirmation code is required" }}
        />

        <CustomButton onPress={handleSubmit(onConfirmPressed)} text="Confirm" />
        <View style={styles.btnContainer}>
          <View>
            <CustomButton
              text="Resend code"
              type="SECONDARY"
              onPress={onResendPressed}
            />
          </View>

          <View>
            <CustomButton
              text="Back to Sign in"
              onPress={onSignInPressed}
              type="SECONDARY"
            />
          </View>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: myColors.pbgc,
    alignItems: "center",
    padding: 20,
  },
  container: {
    width: "100%",
    borderColor: "white",
    borderWidth: 1,
    borderRadius: 10,
    marginVertical: 20,
    padding: 20,
    backgroundColor: myColors.sbgc,
  },
  link: {
    fontWeight: "bold",
    paddingVertical: 10,
    fontSize: 15,
    color: "white",
    width: "100%",
    textAlign: "center",
    textDecorationLine: "underline",
    textDecorationColor: "white",
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    color: "white",
    margin: 10,
  },
  text: {
    width: "100%",
    // justifyContent: "space-around",
    // marginHorizontal: 10,
    color: "#707271",
    fontSize: 12,
    // textAlign: "center",
    marginVertical: 10,
  },
  btnContainer: {
    flexDirection: "row",
    // alignItems: "center",
    justifyContent: "space-between",
  },
});

export default ConfirmEmail;
