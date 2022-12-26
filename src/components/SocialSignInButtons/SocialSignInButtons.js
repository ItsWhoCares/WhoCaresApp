import { View, Text } from "react-native";
import React from "react";
import CustomButton from "../CustomButton";

const onSignInFacebookPressed = () => {
  console.warn("Sign in with Facebook");
};
const onSignInGooglePressed = () => {
  console.warn("Sign in with Google");
};

const SocialSignInButtons = () => {
  return (
    <>
      <CustomButton
        onPress={onSignInFacebookPressed}
        text="Sign In with Facebook"
        bgC="#E7EAF4"
        fgC="#4765A9"
        icon="facebook-f"
        iconColor="#4765A9"
      />
      <CustomButton
        onPress={onSignInGooglePressed}
        text="Sign In with Google"
        bgC="#e3e3e3"
        fgC="#DD4D44"
        icon="google"
        iconColor="#DD4D44"
      />
    </>
  );
};

export default SocialSignInButtons;
