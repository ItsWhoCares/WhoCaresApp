import {
  View,
  Text,
  StyleSheet,
  Image,
  Pressable,
  Alert,
  Modal,
} from "react-native";
import React, { useState, useRef } from "react";
import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import { myColors } from "../../../colors";
dayjs.extend(relativeTime);

import { supabase } from "../../initSupabase";
import { useWindowDimensions } from "react-native";
import { deleteMessage } from "../../../supabaseQueries";
import { Swipeable } from "react-native-gesture-handler";

const Message = ({ message, authUser }) => {
  const [rerender, setRerender] = useState(false);
  const swipeleft = useRef(null);
  const swiperight = useRef(null);
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
    return data.publicUrl;
  };
  const _handleDeleteMessage = () => {
    if (isMyMessage() == false) return;
    if (message.text == "⦸  This message was deleted") return;
    Alert.alert(
      "Delete Message",
      "Are you sure you want to delete this message?",
      [
        {
          text: "Cancel",
          onPress: () => console.log("Cancel Pressed"),
          style: "cancel",
        },
        {
          text: "OK",
          onPress: () => {
            const res = deleteMessage({ id: message.id });
            if (res) console.log("Message deleted successfully");
            else console.log("Message deletion failed");
            message.text = "⦸  This message was deleted";
            setRerender(!rerender);
          },
        },
      ],
      { cancelable: true }
    );
  };
  const _handleDeleteImage = () => {
    if (isMyMessage() == false) return;
    if (message.text == "⦸  This message was deleted") return;
    Alert.alert(
      "Delete Message",
      "Are you sure you want to delete this message?",
      [
        {
          text: "Cancel",
          onPress: () => console.log("Cancel Pressed"),
          style: "cancel",
        },
        {
          text: "OK",
          onPress: () => {
            const res = deleteMessage({ id: message.id, isMedia: true });
            if (res) console.log("Message deleted successfully");
            else console.log("Message deletion failed");
            message.text = "⦸  This message was deleted";
            message.isMedia = false;
            console.log(message);
            setRerender(!rerender);
          },
        },
      ],
      { cancelable: true }
    );
  };
  const _showImage = () => {};

  if (_isMedia())
    return (
      <Pressable
        onPress={_showImage}
        onLongPress={_handleDeleteImage}
        style={({ pressed }) =>
          pressed
            ? [
                styles.root,
                {
                  padding: 5,
                  backgroundColor: isMyMessage()
                    ? myColors.PrimaryMessagePressed
                    : myColors.SecondaryMessagePressed,
                  alignSelf: isMyMessage() ? "flex-end" : "flex-start",
                  borderBottomRightRadius: isMyMessage() ? 2 : 10,
                  borderBottomLeftRadius: isMyMessage() ? 10 : 2,
                },
              ]
            : [
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
              ]
        }>
        <Image
          progressiveRenderingEnabled={true}
          resizeMethod="scale"
          style={{ width: width * 0.7, height: 200, borderRadius: 10 }}
          source={{ uri: getImageUri() }}
        />
        <Text
          style={[
            styles.time,
            {
              paddingTop: 5,
              paddingBottom: 0,
            },
          ]}>
          {dayjs(message.created_at).format("hh:mm a")}
        </Text>
      </Pressable>
    );

  const hehe = () => {
    swipeleft?.current?.close();
    swiperight?.current?.close();
  };
  const swipeContent = () => {
    return (
      <View
        style={{
          backgroundColor: myColors.pbgc,
          width: "10%",
          height: "100%",
          justifyContent: "center",
          alignItems: "center",
        }}>
        <Text style={styles.SwipeTime}>
          {dayjs(message.created_at).format("DD MMM YY")}
        </Text>
      </View>
    );
  };

  if (isMyMessage()) {
    return (
      <Swipeable
        ref={swiperight}
        renderRightActions={swipeContent}
        // overshootRight={false}
        // overshootLeft={false}
        overshootFriction={10}
        onSwipeableWillOpen={hehe}>
        <Pressable
          onLongPress={_handleDeleteMessage}
          style={({ pressed }) =>
            pressed
              ? [
                  styles.root,
                  {
                    backgroundColor: myColors.PrimaryMessagePressed,
                    alignSelf: "flex-end",
                    borderBottomRightRadius: 2,
                    borderBottomLeftRadius: 10,
                  },
                ]
              : [
                  styles.root,
                  {
                    backgroundColor: myColors.PrimaryMessage,
                    alignSelf: "flex-end",
                    borderBottomRightRadius: 2,
                    borderBottomLeftRadius: 10,
                  },
                ]
          }>
          <Text style={styles.text}>{message.text}</Text>
          <Text style={styles.time}>
            {dayjs(message.created_at).format("hh:mm a")}
          </Text>
        </Pressable>
      </Swipeable>
    );
  } else {
    return (
      <Swipeable
        ref={swipeleft}
        renderLeftActions={swipeContent}
        // overshootLeft={false}
        // overshootRight={false}
        overshootFriction={8}
        onSwipeableWillOpen={hehe}>
        <Pressable
          onLongPress={_handleDeleteMessage}
          style={({ pressed }) =>
            pressed
              ? [
                  styles.root,
                  {
                    backgroundColor: isMyMessage()
                      ? myColors.PrimaryMessagePressed
                      : myColors.SecondaryMessagePressed,
                    alignSelf: isMyMessage() ? "flex-end" : "flex-start",
                    borderBottomRightRadius: isMyMessage() ? 2 : 10,
                    borderBottomLeftRadius: isMyMessage() ? 10 : 2,
                  },
                ]
              : [
                  styles.root,
                  {
                    backgroundColor: isMyMessage()
                      ? myColors.PrimaryMessage
                      : myColors.SecondaryMessage,
                    alignSelf: isMyMessage() ? "flex-end" : "flex-start",
                    borderBottomRightRadius: isMyMessage() ? 2 : 10,
                    borderBottomLeftRadius: isMyMessage() ? 10 : 2,
                  },
                ]
          }>
          <Text style={styles.text}>{message.text}</Text>
          <Text style={styles.time}>
            {dayjs(message.created_at).format("hh:mm a")}
          </Text>
        </Pressable>
      </Swipeable>
    );
  }
};

const styles = StyleSheet.create({
  root: {
    margin: 5,
    // padding: 10,
    borderRadius: 10,
    maxWidth: "80%",
    minWidth: "20%",
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
    paddingTop: 10,
    paddingHorizontal: 10,
    color: "white",
  },
  time: {
    paddingBottom: 5,
    paddingRight: 10,
    fontSize: 10,
    color: myColors.secondaryText,
    alignSelf: "flex-end",
  },
  SwipeTime: {
    paddingTop: 5,
    color: myColors.secondaryText,
    fontSize: 12,
    alignSelf: "center",
  },
});
export default Message;
