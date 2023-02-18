import { View, Text, StyleSheet, ScrollView, Alert } from "react-native";
import React, { useState } from "react";
import CustomInput from "../../components/CustomInput/CustomInput";
import CustomButton from "../../components/CustomButton";
import { myColors } from "../../../colors";
import SocialSignInButtons from "../../components/SocialSignInButtons";
import { StackActions, useNavigation } from "@react-navigation/native";
import { useForm, Controller } from "react-hook-form";

//firebase
import { auth } from "../../../firebase";
import {
  createUserWithEmailAndPassword,
  updateProfile,
  sendEmailVerification,
  signOut,
} from "firebase/auth";

const EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i;

const onPrivacyPressed = () => {
  console.warn("Privacy");
};

const SignUp = () => {
  const [loading, setLoading] = useState(false);
  const { control, handleSubmit, watch } = useForm();
  const pwd = watch("password");

  const navigation = useNavigation();
  const onSignInPressed = () => {
    console.warn("Sign in");
    navigation.navigate("SignIn");
  };
  const onRegisterPressed = async (data) => {
    if (loading) return;
    setLoading(true);
    const { name, email, password } = data;
    name.trim();
    email.trim();
    password.trim();
    try {
      //firebase
      const userData = await createUserWithEmailAndPassword(
        auth,
        email,
        password
      );
      await updateProfile(userData.user, {
        displayName: name,
        photoURL: `https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/${Math.floor(
          Math.random() * 4 + 1
        )}.jpg`,
      });
      const response = await sendEmailVerification(userData.user);

      Alert.alert(
        "Success",
        "Please check your email to confirm your account."
      );
      signOut(auth);
      navigation.navigate("SignIn", { email });
    } catch (error) {
      Alert.alert("Oops", error.message);
    } finally {
      setLoading(false);
    }
  };
  const onTermsPressed = () => {
    navigation.navigate("ConfirmEmail");
    console.warn("Terms");
  };

  return (
    <ScrollView
      style={{ backgroundColor: myColors.pbgc }}
      showsVerticalScrollIndicator={false}>
      <View style={styles.root}>
        <Text style={styles.title}>Create an account</Text>
        <View style={styles.container}>
          <CustomInput
            name="name"
            placeholder="Name"
            control={control}
            rules={{
              required: "Name is required",
              minLength: {
                value: 3,
                message: "Name must be at least 3 characters",
              },
              maxLength: {
                value: 15,
                message: "Name must be at most 15 characters",
              },
            }}
          />
          <CustomInput
            name="email"
            placeholder="Email"
            control={control}
            rules={{
              required: "Email is required",
              pattern: { value: EMAIL_REGEX, message: "Invalid email address" },
            }}
          />
          <CustomInput
            name="password"
            placeholder="Password"
            control={control}
            rules={{
              required: "Password is required",
              minLength: {
                value: 6,
                message: "Password must be at least 6 characters",
              },
            }}
            secure={true}
          />
          <CustomInput
            name="confirmPassword"
            placeholder="Confirm Password"
            control={control}
            rules={{
              required: "Passwords do not match",
              validate: (value) => value === pwd || "Passwords do not match",
            }}
            secure={true}
          />
          <CustomButton
            onPress={handleSubmit(onRegisterPressed)}
            text={loading ? "Loading..." : "Register"}
          />
          <Text style={styles.text}>
            By registering, you confirm that you accept our{" "}
            <Text style={{ color: "white" }} onPress={onTermsPressed}>
              Terms of use
            </Text>{" "}
            and{" "}
            <Text style={{ color: "white" }} onPress={onPrivacyPressed}>
              Privacy Policy
            </Text>
          </Text>
        </View>
        <SocialSignInButtons />
        <Text style={styles.link} onPress={onSignInPressed}>
          Already have an account?{" "}
          <Text style={{ color: myColors.primaryBtn }}>Sign In</Text>
        </Text>
      </View>
    </ScrollView>
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
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
    color: "white",
    margin: 10,
  },
  text: {
    color: "#707271",
    fontSize: 12,
    textAlign: "center",
    marginVertical: 10,
  },
});

export default SignUp;
