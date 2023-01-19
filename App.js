import "react-native-gesture-handler";

import { StyleSheet, SafeAreaView, StatusBar, LogBox } from "react-native";
import React from "react";
import Navigation from "./src/components/Navigation";
import { myColors } from "./colors";

import * as NavigationBar from "expo-navigation-bar";

import { GestureHandlerRootView } from "react-native-gesture-handler";

const App = () => {
  // Auth.signOut();
  React.useEffect(() => {
    LogBox.ignoreLogs([
      "AsyncStorage has been extracted from react-native core and will be removed in a future release. It can now be installed and imported from '@react-native-async-storage/async-storage' instead of 'react-native'. See https://github.com/react-native-async-storage/async-storage",
    ]);
  }, []);
  NavigationBar.setBackgroundColorAsync("black");
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaView style={styles.root}>
        <StatusBar barStyle={"light-content"} backgroundColor={"black"} />
        <Navigation />
      </SafeAreaView>
    </GestureHandlerRootView>
  );
};

const styles = StyleSheet.create({
  root: {
    flex: 1,
    // marginTop: Platform.OS === "android" ? StatusBar.currentHeight : 0,
    backgroundColor: myColors.pbgc,
  },
});

export default App;
