import * as Notifications from "expo-notifications";
import * as Device from "expo-device";
import { Platform } from "react-native";
import { auth } from "../firebase";

import { addUserPushToken } from "../supabaseQueries";

export const registerForPushNotificationsAsync = async () => {
  if (Device.isDevice) {
    const { status: existingStatus } =
      await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;
    if (existingStatus !== "granted") {
      const { status } = await Notifications.requestPermissionsAsync();
      finalStatus = status;
    }
    if (finalStatus !== "granted") {
      alert("Failed to get push token for push notification!");
      return;
    }
    const token = (await Notifications.getExpoPushTokenAsync()).data;
    console.log(token);
    await addUserPushToken({ UserID: auth.currentUser.uid, PushToken: token });
  } else {
    // alert("Must use physical device for Push Notifications");
  }

  if (Platform.OS === "android") {
    Notifications.setNotificationChannelAsync("default", {
      name: "default",
      importance: Notifications.AndroidImportance.MAX,
      vibrationPattern: [0, 250, 250, 250],
      lightColor: "#FF231F7C",
    });
  }
};

import { supabase } from "./initSupabase";

export const sendPushNotification = async ({ UserID, message }) => {
  const { data, error } = await supabase
    .from("UserToken")
    .select("PushToken")
    .eq("id", UserID);
  if (error) {
    console.log(error);
    return null;
  }
  if (data.length === 0) {
    return null;
  }
  const PushToken = data[0].PushToken;
  const message1 = {
    to: PushToken,
    sound: "default",
    title: message.title,
    body: message.body,
    data: { data: "goes here" },
  };

  const response = await fetch("https://exp.host/--/api/v2/push/send", {
    method: "POST",
    headers: {
      //   Accept: "application/json",
      //   "Accept-encoding": "gzip, deflate",
      "Content-Type": "application/json",
    },
    body: JSON.stringify(message1),
  });
  console.log(JSON.stringify(response, null, "\t"));
};
