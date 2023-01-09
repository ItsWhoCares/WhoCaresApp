import { View, Text, ActivityIndicator, StyleSheet } from "react-native";
import React, { useEffect, useState } from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";

import SignIn from "../../screens/SignIn/SignIn";
import SignUp from "../../screens/SignUp/SignUp";
import ConfirmEmail from "../../screens/ConfirmEmail";
import Home from "../../screens/Home";
import ResetPassword from "../../screens/ResetPassword";
import NewPassword from "../../screens/NewPassword";
import ChatRoom from "../../screens/ChatRoom";
import { myColors } from "../../../colors";
import Settings from "../../screens/Settings";
import Search from "../../screens/Search";

import { auth } from "../../../firebase";
import { onAuthStateChanged } from "firebase/auth";

// import { Linking } from "react-native";
// import * as Notifications from "expo-notifications";

const Navigation = () => {
  const [user, setUser] = useState(undefined);
  const checkUser = async () => {
    onAuthStateChanged(auth, (u) => {
      if (u && u.emailVerified) {
        setUser(true);
        // getUserData();
      } else {
        setUser(false);
        // setUserData(null);
      }
    });
  };
  useEffect(() => {
    checkUser();
  }, []);
  // useEffect(() => {
  //   const listener = Hub.listen("auth", (data) => {
  //     if (data.payload.event === "signIn" || data.payload.event === "signOut") {
  //       checkUser();
  //     }
  //   });
  //   return () => {
  //     listener();
  //   };
  // }, []);
  if (user === undefined)
    return (
      <View style={{ flex: 1, justifyContent: "center", alignItems: "center" }}>
        <ActivityIndicator />
      </View>
    );
  const Stack = createNativeStackNavigator();
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: true,
        }}>
        {user ? (
          <>
            <Stack.Screen name="Home" component={Home} />
            <Stack.Screen name="ChatRoom" component={ChatRoom} />
            <Stack.Screen name="Search" component={Search} />
            <Stack.Screen name="Settings" component={Settings} />
          </>
        ) : (
          <>
            <Stack.Screen
              name="SignIn"
              component={SignIn}
              options={{ headerShown: false }}
            />
            <Stack.Screen
              name="SignUp"
              component={SignUp}
              options={{ headerShown: false }}
            />
            <Stack.Screen
              name="ConfirmEmail"
              component={ConfirmEmail}
              options={{ headerShown: false }}
            />
            <Stack.Screen
              name="ResetPassword"
              component={ResetPassword}
              options={{ headerShown: false }}
            />
            <Stack.Screen
              name="NewPassword"
              component={NewPassword}
              options={{ headerShown: false }}
            />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};

const styles = StyleSheet.create({
  header: {},
});

export default Navigation;

/*linking={{
        config: {
          // Configuration for linking
        },
        async getInitialURL() {
          // First, you may want to do the default deep link handling
          // Check if app was opened from a deep link
          const url = await Linking.getInitialURL();

          if (url != null) {
            return url;
          }

          // Handle URL from expo push notifications
          const response =
            await Notifications.getLastNotificationResponseAsync();
          const url1 = "com.wca.myapp://";

          return url1;
        },
        subscribe(listener) {
          const onReceiveURL = ({ url }) => listener(url);

          // Listen to incoming links from deep linking
          const surl = Linking.addEventListener("url", onReceiveURL);

          // Listen to expo push notifications
          const subscription =
            Notifications.addNotificationResponseReceivedListener(
              (response) => {
                const url = "com.wca.myapp://";

                // Any custom logic to see whether the URL needs to be handled
                //...

                // Let React Navigation handle the URL
                listener(url);
              }
            );

          return () => {
            // Clean up the event listeners
            surl.remove();
            subscription.remove();
          };
        },
      }}

*/
