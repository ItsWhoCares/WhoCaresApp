import { supabase } from "./src/initSupabase";

export const addUser = async (
  id,
  name,
  status = "Hey there, I'am using WC.",
  image = `https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/${Math.floor(
    Math.random() * 4 + 1
  )}.jpg`
) => {
  console.log(id);
  //check if user already exists
  const { data, error } = await supabase.from("User").select("*").eq("id", id);
  if (error) {
    console.log("first", error);
    return false;
  }
  if (data.length > 0) {
    return true;
  }

  //itswhocaresman@gmail.com
  //insert user

  const res = await supabase.from("User").insert([{ id, name, status, image }]);
  if (res.error) {
    console.log("Second", res.error);
    return false;
  }
  return true;
};

export const listUsers = async () => {
  const { data, error } = await supabase.from("User").select("*");
  if (error) {
    console.log(error);
    return [];
  }
  return data;
};

export const getUserByID = async (id) => {
  const { data, error } = await supabase.from("User").select("*").eq("id", id);
  if (error) {
    console.log(error);
    return null;
  }
  return data[0];
};

export const createChatRoom = async (user1, user2) => {
  // console.log(user1, user2);
  // return null;
  // const { data, error } = await supabase
  //   .from("ChatRoom")
  //   .select("*")
  //   .or(
  //     `user1_id=eq.${user1.id},user2_id=eq.${user2.id}`,
  //     `user1_id=eq.${user2.id},user2_id=eq.${user1.id}`
  //   );
  // if (error) {
  //   console.log(error);
  //   return null;
  // }
  // if (data.length > 0) {
  //   return data[0];
  // }
  const { data, error } = await supabase
    .from("ChatRoom")
    .insert([{ LastMessageID: "b15f0db2-87f6-4358-874a-4297ee170240" }]) //here
    .select();

  if (error) {
    console.log(error);
    return null;
  }

  const res1 = await supabase.from("UserChatRoom").insert([
    { UserID: user1, ChatRoomID: data[0].id },
    { UserID: user2, ChatRoomID: data[0].id },
  ]);
  return data[0];
};

export const listUserChatRooms = async (id) => {
  const { data: allChatRooms, error } = await supabase
    .from("UserChatRoom")
    .select("ChatRoomID")
    .eq("UserID", id);
  if (error) {
    console.log(error);
    return [];
  }
  // console.log("AllChatRooms", JSON.stringify(allChatRooms, null, "\t"));

  const { data: chatRooms, error: err } = await supabase
    .from("UserChatRoom")
    .select("User(*),ChatRoom(*)")
    .in(
      "ChatRoomID",
      allChatRooms.map((chatRoom) => chatRoom.ChatRoomID)
    );

  if (err) {
    console.log(err);
  }
  // console.log("AllUsers", JSON.stringify(chatRooms, null, "\t"));

  //remove the current user from the list
  const chatRooms1 = chatRooms.filter((chatRoom) => chatRoom.User.id !== id);

  //add last message to the chat room
  const { data: messages, error: err1 } = await supabase
    .from("Message")
    .select("*")
    .in(
      "id",
      chatRooms1.map((chatRoom) => chatRoom.ChatRoom.LastMessageID)
    );
  if (err1) {
    console.log(err1);
  }
  // console.log("AllMessages", JSON.stringify(messages, null, "\t"));

  // console.log("OtherUser", JSON.stringify(chatRooms1, null, "\t"));

  // console.log("Mesages", JSON.stringify(messages, null, "\t"));
  //merge the last message with the chat room
  chatRooms1.forEach((chatRoom) => {
    //if last message is null, then return last message as null
    if (chatRoom.ChatRoom.LastMessageID === null) {
      chatRoom.ChatRoom.LastMessage = null;
      return;
    }
    const message = messages.find(
      (message) => message.id === chatRoom.ChatRoom.LastMessageID
    );
    chatRoom.ChatRoom.LastMessage = message;
  });

  // const message = messages?.find(
  //   (message) => message.id === chatRoom.ChatRoom.LastMessageID
  // );
  // chatRoom.ChatRoom.LastMessage = message;

  // console.log("NewOtherUser", JSON.stringify(chatRooms1, null, "\t"));

  return chatRooms1;
};

export const getChatRoomByID = async (id) => {
  const { data, error } = await supabase
    .from("ChatRoom")
    .select(
      "*, LastMessage:Message!ChatRoom_LastMessageID_fkey(created_at, text, UserID)[0]"
    )
    .eq("id", id);
  if (error) {
    console.log(error);
    return null;
  }
  return data[0];
};

export const createMessage = async ({ text, UserID, ChatRoomID }) => {
  const { data, error } = await supabase
    .from("Message")
    .insert([{ text, UserID, ChatRoomID }])
    .select();
  if (error) {
    console.log(error);
    return null;
  }
  return data[0];
};

export const updateChatRoomLastMessage = async ({
  ChatRoomID,
  LastMessageID,
}) => {
  const { data, error } = await supabase
    .from("ChatRoom")
    .update({ LastMessageID })
    .eq("id", ChatRoomID)
    .select();
  if (error) {
    console.log(error);
    return null;
  }
  return data[0];
};

export const listMessagesByChatRoom = async (ChatRoomID) => {
  const { data, error } = await supabase
    .from("Message")
    .select("*")
    .eq("ChatRoomID", ChatRoomID)
    .order("created_at", { ascending: false });
  if (error) {
    console.log(error);
    return [];
  }
  return data;
};

export const temp = async (id) => {
  const { data, error } = await supabase
    .from("User")
    .select("ChatRoom(*)")
    .eq("UserID", id);
  if (error) {
    console.log(error);
    return [];
  }
  console.log(data);
};

export const getCommonChatRoom = async ({ authUserID, otherUserID }) => {
  const { data: data1, error: err } = await supabase
    .from("UserChatRoom")
    .select("ChatRoomID")
    .eq("UserID", otherUserID);
  if (err) {
    console.log(err);
    return null;
  }
  // console.log(data1);

  const { data, error } = await supabase
    .from("UserChatRoom")
    .select("ChatRoom(*)")
    .eq("UserID", authUserID)
    .in(
      "ChatRoomID",
      data1.map((chatRoom) => chatRoom.ChatRoomID)
    );

  if (error) {
    console.log(error);
    return null;
  }
  if (data.length === 0) {
    return null;
  }
  // console.log(data[0].ChatRoom);
  return data[0].ChatRoom;

  // const { data, error } = await supabase
  //   .from("UserChatRoom")
  //   .select("ChatRoom(*)")
  //   .eq("UserID", authUserID)
  //   .in(
  //     "ChatRoomID",
  //     supabase
  //       .from("UserChatRoom")
  //       .select("ChatRoomID")
  //       .eq("UserID", otherUserID)

  //   );

  // if (error) {
  //   console.log(error);
  //   return null;
  // }
  // if (data.length === 0) {
  //   return null;
  // }
  // console.log(data[0].ChatRoom);
  // return data[0].ChatRoom;
};

import * as Notifications from "expo-notifications";
import * as Device from "expo-device";
import { auth } from "./firebase";

export const addUserPushToken = async ({
  UserID = auth.currentUser.uid,
  PushToken = "",
}) => {
  if (PushToken === "" && Device.isDevice) {
    const token = (await Notifications.getExpoPushTokenAsync()).data;
    PushToken = token;
  }
  if (!Device.isDevice) return null;
  //check if the user already has a push token
  const { data, error } = await supabase
    .from("UserToken")
    .select("*")
    .eq("id", UserID);
  if (error) {
    console.log(error);
    return null;
  }
  if (data.length === 0) {
    //if user does not have a push token, add one
    const { data, error } = await supabase
      .from("UserToken")
      .insert([{ id: UserID, PushToken }]);
    if (error) {
      console.log(error);
      return null;
    }
    return true;
  } else {
    //if user already has a push token, update it
    const { data, error } = await supabase
      .from("UserToken")
      .update({ PushToken })
      .eq("id", UserID);
    if (error) {
      console.log(error);
      return null;
    }
    return true;
  }
};

export const getUserPushToken = async (UserID) => {
  const { data, error } = await supabase
    .from("UserToken")
    .select("*")
    .eq("id", UserID);
  if (error) {
    console.log(error);
    return null;
  }
  return data[0];
};
