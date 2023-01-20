import React, { useState } from "react";
import { View, TextInput, Button, StyleSheet, Alert } from "react-native";
import { myColors } from "../../../colors";
import { AntDesign, MaterialIcons } from "@expo/vector-icons";
// import { createMessage, updateChatRoom } from "../../graphql/mutations";

import { auth } from "../../../firebase";
import {
  createMessage,
  updateChatRoomLastMessage,
  getCommonChatRoom,
  getUserByID,
} from "../../../supabaseQueries";

import { sendPushNotification } from "../../notification";
import { decode } from "base64-arraybuffer";

import * as ImagePicker from "expo-image-picker";

const ChatInput = ({ chatRoom, otherUser, onTyping }) => {
  const [message, setMessage] = useState("");
  // const [otherUser, setOtherUser] = useState(OtherUser);
  const [loading, setLoading] = useState(false);

  const handleSend = async () => {
    if (loading) return;
    setLoading(true);
    if (message === "") return;
    // send the message to the chat server
    // console.warn(`Sending: ${message}`);

    // send the message to the backend
    const newMessageData = await createMessage({
      ChatRoomID: chatRoom.id,
      text: message.trim(),
      UserID: auth.currentUser.uid,
    });
    // console.log("New Message", newMessageData);
    setMessage("");

    //Update the last message in the chat room
    const res = await updateChatRoomLastMessage({
      ChatRoomID: chatRoom.id,
      LastMessageID: newMessageData.id,
    });
    setLoading(false);

    //send push notification
    // console.log(otherUser);
    const oUser = await getUserByID(auth.currentUser.uid);
    const notificationMessage = {
      title: oUser.name,
      body: newMessageData.text,
    };
    sendPushNotification({
      UserID: otherUser.id,
      message: notificationMessage,
    });

    // console.log("otherUser", otherUser);
  };

  // const tempp = async () => {
  //   console.log("tempp");
  //   const res = await getCommonChatRoom({
  //     authUserID: "usOWdwZr9XeOwdkIyjbJixXDmC12",
  //     otherUserID: "JK2Ww9wLsuTXgFVwj9U6BCxUw704",
  //   });
  // };
  // const [image, setImage] = useState(null);
  const handleImagePick = async () => {
    // No permissions request is necessary for launching the image library
    let result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.All,
      allowsEditing: true,
      aspect: [4, 3],
      quality: 1,
      base64: true,
    });

    // console.log(JSON.stringify(result, null, "\t"));

    if (!result.canceled) {
      // setImage(result.assets[0].uri);
      _uploadImage(result.assets[0], chatRoom.id, otherUser.id);
    }
  };

  return (
    <View style={styles.inputContainer}>
      <AntDesign
        name="plus"
        size={24}
        color="white"
        onPress={handleImagePick}
      />
      <TextInput
        value={message}
        onChangeText={(text) => {
          setMessage(text);
          onTyping(text);
        }}
        placeholder="Message..."
        placeholderTextColor={"gray"}
        style={[
          styles.input,
          { height: Math.max(40, message.length * 0.5 + 40) },
        ]}
        returnKeyType="send"
        onSubmitEditing={handleSend}
        multiline={true}
      />
      <MaterialIcons
        onPress={handleSend}
        name="send"
        size={24}
        color="royalblue"
      />
    </View>
  );
};

const styles = StyleSheet.create({
  inputContainer: {
    flexDirection: "row",
    backgroundColor: myColors.SecondaryMessage,
    borderRadius: 25,
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: 8,
    paddingVertical: 4,
    marginHorizontal: 15,
    // marginVertical: 10,
    marginBottom: 10,
  },
  input: {
    flex: 1,
    height: 40,
    backgroundColor: myColors.SecondaryMessage,
    borderColor: myColors.SecondaryMessage,
    borderWidth: 1,
    paddingHorizontal: 10,
    marginRight: 8,
    borderRadius: 20,
    color: "white",
  },
  button: {
    width: 80,
  },
});

import { supabase } from "../../initSupabase";

const _uploadImage = async (image, chatRoomID, oUserID) => {
  //upload image to supabase using base64 to array buffer
  const ext = image.uri.substring(image.uri.lastIndexOf(".") + 1);
  if (ext != "png" || ext != "jpg" || ext != "jpeg") {
    Alert.alert("Error", "Only png, jpg, and jpeg are supported");
    return;
  }
  const base64 = image.base64;
  const buffer = decode(base64);

  const filename = image.uri.substring(image.uri.lastIndexOf("/") + 1);

  const { data, error } = await supabase.storage
    .from(`chatroom`)
    .upload(`${chatRoomID}/${filename}`, buffer, {
      contentType: `image/${ext}`,
    });
  if (error) {
    console.log(error);
    Alert.alert("Error", "Error uploading image");
    return;
  }
  console.log(image.uri.substring(image.uri.lastIndexOf("/") + 1));
  console.log(data);
  const res = await createMessage({
    ChatRoomID: chatRoomID,
    text: data.path,
    UserID: auth.currentUser.uid,
    isMedia: true,
  });
  const user = await getUserByID(auth.currentUser.uid);
  const mes = {
    title: user.name,
    body: "Image",
  };
  sendPushNotification({
    UserID: oUserID,
    message: mes,
  });
};

export default ChatInput;
