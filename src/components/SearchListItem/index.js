import { View, Text, StyleSheet, Image, Pressable } from "react-native";
import React, { useState, useEffect } from "react";
import { useNavigation } from "@react-navigation/native";


import dayjs from "dayjs";
import relativeTime from "dayjs/plugin/relativeTime";
import { myColors } from "../../../colors";
dayjs.extend(relativeTime);

import { auth } from "../../../firebase";
import { createChatRoom, getCommonChatRoom } from "../../../supabaseQueries";

const SearchListItem = ({ user }) => {
  const navigation = useNavigation();
  const [authUser, setAuthUser] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchUser = async () => {
      const userInfo = auth.currentUser;
      // console.log(userInfo);
      setAuthUser(userInfo);
    };
    fetchUser();
  }, []);

  const onPress = async () => {
    //Check if the user is already in the chat room
    if (loading) return;
    setLoading(true);

    const commonChatRoom = await getCommonChatRoom({
      authUserID: auth.currentUser.uid,
      otherUserID: user.id,
    });
    console.log("other user", user.id, "auth user", auth.currentUser.uid);
    console.log("here", commonChatRoom);
    if (commonChatRoom) {
      navigation.navigate("ChatRoom", {
        id: commonChatRoom.id,
        user: {
          id: user.id,
          name: user.name,
          image: user.image,
        },
      });
      return;
    }

    // if not create a new chat room
    const newChatRoomData = await createChatRoom(auth.currentUser.uid, user.id);
    console.log(newChatRoomData);
    navigation.navigate("ChatRoom", {
      id: newChatRoomData.id,
      user: {
        id: user.id,
        name: user.name,
        image: user.image,
      },
    });
    setLoading(false);
  };
  if (authUser?.uid == user.id) {
    return null;
  }

  return (
    <Pressable style={styles.container} onPress={onPress}>
      <Image style={styles.image} source={{ uri: user.image }} />
      <View style={styles.content}>
        <View style={styles.row}>
          <Text numberOfLines={1} style={styles.name}>
            {user.name}
          </Text>
          {user.createdAt !== undefined && (
            <Text numberOfLines={2} style={styles.subTitle}>
              {dayjs(user.createdAt).fromNow(true)}
            </Text>
          )}
        </View>

        {user.status !== undefined && (
          <Text numberOfLines={2} style={styles.subTitle}>
            {user.status}
          </Text>
        )}
      </View>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: "row",
    marginHorizontal: 10,
    marginVertical: 5,
    height: 70,
  },
  content: {
    flex: 1,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: "grey",
  },
  image: {
    width: 60,
    height: 60,
    borderRadius: 30,
    marginRight: 10,
  },
  row: {
    flexDirection: "row",
    marginBottom: 5,
  },
  name: {
    // fontWeight: "bold",
    fontSize: 16,
    color: "white",
    flex: 1,
  },
  subTitle: {
    color: myColors.secondaryText,
  },
});

export default SearchListItem;
