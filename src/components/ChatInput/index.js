import React, { useState } from "react";
import { View, TextInput, Button, StyleSheet } from "react-native";
import { myColors } from "../../../colors";
import { AntDesign, MaterialIcons } from "@expo/vector-icons";
// import { createMessage, updateChatRoom } from "../../graphql/mutations";

import { auth } from "../../../firebase";
import {
  createMessage,
  updateChatRoomLastMessage,
  getCommonChatRoom,
} from "../../../supabaseQueries";

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
      text: message,
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

    // send push notification
    // const notificationMessage = {
    //   title: otherUser.name,
    //   body: newMessageData.text,
    // };
    // sendPushNotification({
    //   UserID: otherUser.id,
    //   message: notificationMessage,
    // });

    // console.log("otherUser", otherUser);
  };

  // const tempp = async () => {
  //   console.log("tempp");
  //   const res = await getCommonChatRoom({
  //     authUserID: "usOWdwZr9XeOwdkIyjbJixXDmC12",
  //     otherUserID: "JK2Ww9wLsuTXgFVwj9U6BCxUw704",
  //   });
  // };

  return (
    <View style={styles.inputContainer}>
      <AntDesign name="plus" size={24} color="white" />
      <TextInput
        value={message}
        onChangeText={(text) => {
          setMessage(text);
          onTyping(text);
        }}
        placeholder="Message..."
        placeholderTextColor={"gray"}
        style={styles.input}
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

export default ChatInput;
