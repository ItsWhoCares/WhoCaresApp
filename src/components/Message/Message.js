import { View, Text, StyleSheet, Image } from "react-native";
import React from "react";
import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import { myColors } from "../../../colors";
dayjs.extend(relativeTime);

import { supabase } from "../../initSupabase";
import { useWindowDimensions } from "react-native";

const Message = ({ message, authUser }) => {
  const { height, width } = useWindowDimensions();
  // console.log(authUser);
  const isMyMessage = () => {
    return message?.UserID === authUser;
  };
  const _isMedia = () => {
    return message?.isMedia == true ? true : false;
  };
  const getImageUri = () => {
    const { data } = supabase.storage
      .from("chatroom")
      .getPublicUrl(message.text);
    console.log(data);
    return data.publicUrl;
  };

  if (_isMedia())
    return (
      <View
        style={[
          styles.root,
          {
            padding: 5,
            backgroundColor: isMyMessage()
              ? myColors.PrimaryMessage
              : myColors.SecondaryMessage,
            alignSelf: isMyMessage() ? "flex-end" : "flex-start",
            borderBottomRightRadius: isMyMessage() ? 2 : 10,
            borderBottomLeftRadius: isMyMessage() ? 10 : 2,
          },
        ]}>
        <Image
          progressiveRenderingEnabled={true}
          resizeMethod="scale"
          style={{ width: width * 0.7, height: 200, borderRadius: 10 }}
          source={{ uri: getImageUri() }}
        />
        {/* <Text style={styles.time}>
        {dayjs(message.createdAt).hour() +
          ":" +
          dayjs(message.createdAt).minute()}
      </Text> */}
      </View>
    );

  return (
    <View
      style={[
        styles.root,
        {
          backgroundColor: isMyMessage()
            ? myColors.PrimaryMessage
            : myColors.SecondaryMessage,
          alignSelf: isMyMessage() ? "flex-end" : "flex-start",
          borderBottomRightRadius: isMyMessage() ? 2 : 10,
          borderBottomLeftRadius: isMyMessage() ? 10 : 2,
        },
      ]}>
      <Text style={styles.text}>{message.text}</Text>
      {/* <Text style={styles.time}>
        {dayjs(message.createdAt).hour() +
          ":" +
          dayjs(message.createdAt).minute()}
      </Text> */}
    </View>
  );
};

const styles = StyleSheet.create({
  root: {
    margin: 5,
    padding: 10,
    borderRadius: 10,
    maxWidth: "80%",
    //shadow
    shadowColor: "#fff",
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.18,
    shadowRadius: 1.0,

    elevation: 1,
  },
  text: {
    color: "white",
  },
  time: {
    color: myColors.subTitle,
    alignSelf: "flex-end",
  },
});
export default Message;
